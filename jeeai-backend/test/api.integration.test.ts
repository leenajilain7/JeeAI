import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { after, before, test } from 'node:test';
import request from 'supertest';

import { createApp } from '../src/app.js';
import { disconnectDatabase, getPrismaClient } from '../src/database/prisma.js';
import { sampleUserId, seedDevelopmentData } from '../src/database/seed-data.js';

const databaseUrl = process.env.TEST_DATABASE_URL;
const skipReason = databaseUrl ? false : 'TEST_DATABASE_URL is not configured';
const prisma = databaseUrl ? getPrismaClient() : undefined;
const app = createApp({ userIdResolver: () => sampleUserId });

before(async () => {
  if (prisma) await seedDevelopmentData(prisma);
});

after(async () => {
  await disconnectDatabase();
});

test('GET /api/contacts returns the development user contacts', { skip: skipReason }, async () => {
  const response = await request(app).get('/api/contacts');

  assert.equal(response.status, 200);
  assert.equal(response.body.data.length, 3);
  assert.deepEqual(response.body.pagination, { page: 1, limit: 20, total: 3, totalPages: 1 });
});

test('GET /api/contacts supports name search and pagination', { skip: skipReason }, async () => {
  const search = await request(app).get('/api/contacts?search=maya');
  const page = await request(app).get('/api/contacts?page=2&limit=1');

  assert.equal(search.status, 200);
  assert.equal(search.body.data.length, 1);
  assert.equal(search.body.data[0].name, 'Maya Perera');
  assert.equal(page.status, 200);
  assert.equal(page.body.data.length, 1);
  assert.equal(page.body.pagination.totalPages, 3);
});

test('GET /api/contacts/:id validates IDs and returns 404 for missing contacts', { skip: skipReason }, async () => {
  const invalid = await request(app).get('/api/contacts/not-a-uuid');
  const missing = await request(app).get(`/api/contacts/${randomUUID()}`);

  assert.equal(invalid.status, 400);
  assert.equal(missing.status, 404);
  assert.equal(missing.body.error.code, 'CONTACT_NOT_FOUND');
});

test('contact access is limited to the resolved user', { skip: skipReason }, async () => {
  assert.ok(prisma);
  const otherUser = await prisma.user.create({
    data: { email: `other-contact-${randomUUID()}@example.test`, displayName: 'Other Contact Owner' },
    include: { contacts: true },
  });
  try {
    const otherContact = await prisma.contact.create({
      data: { userId: otherUser.id, name: 'Private Contact' },
    });
    const response = await request(app).get(`/api/contacts/${otherContact.id}`);
    assert.equal(response.status, 404);
  } finally {
    await prisma.user.delete({ where: { id: otherUser.id } });
  }
});

test('GET /api/conversations returns contacts and latest message previews', { skip: skipReason }, async () => {
  const response = await request(app).get('/api/conversations');

  assert.equal(response.status, 200);
  assert.equal(response.body.data.length, 3);
  assert.ok(response.body.data.every((item: { contact: unknown; latestMessage: unknown; unreadCount: number }) =>
    item.contact && item.latestMessage && typeof item.unreadCount === 'number'));
  assert.deepEqual(response.body.pagination, { page: 1, limit: 20, total: 3, totalPages: 1 });
});

test('GET /api/conversations supports platform and contact search filters', { skip: skipReason }, async () => {
  const platform = await request(app).get('/api/conversations?platform=WHATSAPP');
  const search = await request(app).get('/api/conversations?search=noah');
  const invalidPlatform = await request(app).get('/api/conversations?platform=TELEGRAM');

  assert.equal(platform.status, 200);
  assert.equal(platform.body.data.length, 1);
  assert.equal(platform.body.data[0].platform, 'WHATSAPP');
  assert.equal(search.status, 200);
  assert.equal(search.body.data.length, 1);
  assert.equal(search.body.data[0].contact.name, 'Noah Silva');
  assert.equal(invalidPlatform.status, 400);
});

test('GET conversation details includes the latest message and hides other users conversations', { skip: skipReason }, async () => {
  assert.ok(prisma);
  const conversation = await prisma.conversation.findFirstOrThrow({ where: { userId: sampleUserId } });
  const response = await request(app).get(`/api/conversations/${conversation.id}`);
  const invalid = await request(app).get('/api/conversations/not-a-uuid');

  assert.equal(response.status, 200);
  assert.equal(response.body.id, conversation.id);
  assert.equal('userId' in response.body, false);
  assert.ok(response.body.contact);
  assert.ok(response.body.latestMessage);
  assert.equal(invalid.status, 400);

  const otherUser = await prisma.user.create({
    data: {
      email: `other-conversation-${randomUUID()}@example.test`,
      displayName: 'Other Conversation Owner',
      contacts: { create: { name: 'Other Conversation Contact' } },
    },
    include: { contacts: true },
  });
  try {
    const privateConversation = await prisma.conversation.create({
      data: {
        userId: otherUser.id,
        contactId: otherUser.contacts[0].id,
        platform: 'WHATSAPP',
      },
    });
    const denied = await request(app).get(`/api/conversations/${privateConversation.id}`);
    assert.equal(denied.status, 404);
  } finally {
    await prisma.user.delete({ where: { id: otherUser.id } });
  }
});

test('PATCH conversation read clears its unread count', { skip: skipReason }, async () => {
  assert.ok(prisma);
  const conversation = await prisma.conversation.findFirstOrThrow({
    where: { userId: sampleUserId, platform: 'WHATSAPP' },
  });
  await prisma.conversation.update({ where: { id: conversation.id }, data: { unreadCount: 4 } });

  const response = await request(app).patch(`/api/conversations/${conversation.id}/read`);

  assert.equal(response.status, 200);
  assert.equal(response.body.unreadCount, 0);
});

test('GET conversation messages returns chronological paginated message data', { skip: skipReason }, async () => {
  assert.ok(prisma);
  const conversation = await prisma.conversation.findFirstOrThrow({
    where: { userId: sampleUserId, platform: 'INSTAGRAM' },
  });
  const response = await request(app).get(`/api/conversations/${conversation.id}/messages?limit=1`);
  const invalid = await request(app).get('/api/conversations/nope/messages');

  assert.equal(response.status, 200);
  assert.equal(response.body.data.length, 1);
  assert.equal(response.body.pagination.total, 2);
  assert.equal(response.body.pagination.totalPages, 2);
  assert.ok(['INCOMING', 'OUTGOING'].includes(response.body.data[0].direction));
  assert.ok(response.body.data[0].status);
  assert.equal(invalid.status, 400);

  const allMessages = await request(app).get(`/api/conversations/${conversation.id}/messages?limit=100`);
  const timestamps = allMessages.body.data.map((message: { createdAt: string }) => Date.parse(message.createdAt));
  assert.deepEqual(timestamps, [...timestamps].sort((left: number, right: number) => left - right));
});

test('POST conversation message stores an outgoing simulation and updates last activity', { skip: skipReason }, async () => {
  assert.ok(prisma);
  const conversation = await prisma.conversation.findFirstOrThrow({
    where: { userId: sampleUserId, platform: 'WHATSAPP' },
  });
  const oldLastMessageAt = new Date(Date.now() - 60_000);
  await prisma.conversation.update({
    where: { id: conversation.id },
    data: { lastMessageAt: oldLastMessageAt },
  });

  const response = await request(app)
    .post(`/api/conversations/${conversation.id}/messages`)
    .send({ content: '  Simulated local reply  ', direction: 'INCOMING', userId: randomUUID() });
  const updatedConversation = await prisma.conversation.findFirstOrThrow({
    where: { id: conversation.id, userId: sampleUserId },
  });

  assert.equal(response.status, 201);
  assert.equal(response.body.content, 'Simulated local reply');
  assert.equal(response.body.direction, 'OUTGOING');
  assert.equal(response.body.status, 'SENT');
  assert.ok(updatedConversation.lastMessageAt);
  assert.ok(updatedConversation.lastMessageAt.getTime() > oldLastMessageAt.getTime());
  assert.equal(updatedConversation.lastMessageAt.toISOString(), response.body.createdAt);
});

test('POST rejects empty messages, invalid IDs, and conversations owned by another user', { skip: skipReason }, async () => {
  assert.ok(prisma);
  const conversation = await prisma.conversation.findFirstOrThrow({ where: { userId: sampleUserId } });
  const empty = await request(app)
    .post(`/api/conversations/${conversation.id}/messages`)
    .send({ content: '   ' });
  const invalidId = await request(app)
    .post('/api/conversations/not-a-uuid/messages')
    .send({ content: 'Should be rejected.' });

  assert.equal(empty.status, 400);
  assert.equal(invalidId.status, 400);

  const otherUser = await prisma.user.create({
    data: {
      email: `other-message-${randomUUID()}@example.test`,
      displayName: 'Other Message Owner',
      contacts: { create: { name: 'Private Message Contact' } },
    },
    include: { contacts: true },
  });
  try {
    const privateConversation = await prisma.conversation.create({
      data: {
        userId: otherUser.id,
        contactId: otherUser.contacts[0].id,
        platform: 'WHATSAPP',
      },
    });
    const denied = await request(app)
      .post(`/api/conversations/${privateConversation.id}/messages`)
      .send({ content: 'Should not be stored.' });
    const stored = await prisma.message.count({ where: { conversationId: privateConversation.id } });
    assert.equal(denied.status, 404);
    assert.equal(stored, 0);
  } finally {
    await prisma.user.delete({ where: { id: otherUser.id } });
  }
});

test('API user scope fails closed when no development resolver is configured', async () => {
  const response = await request(createApp()).get('/api/contacts');

  assert.equal(response.status, 503);
  assert.equal(response.body.error.code, 'AUTHENTICATION_UNAVAILABLE');
});
