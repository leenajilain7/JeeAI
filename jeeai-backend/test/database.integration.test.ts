import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { after, test } from 'node:test';
import request from 'supertest';

import { createApp } from '../src/app.js';
import { disconnectDatabase } from '../src/database/prisma.js';
import { PrismaClient } from '../src/generated/prisma/client.js';
import { PrismaPg } from '@prisma/adapter-pg';
import { sampleMessageIds, sampleUserId, seedDevelopmentData } from '../src/database/seed-data.js';

const testDatabaseUrl = process.env.TEST_DATABASE_URL;
const client = testDatabaseUrl
  ? new PrismaClient({ adapter: new PrismaPg({ connectionString: testDatabaseUrl }) })
  : undefined;
const skipReason = testDatabaseUrl ? false : 'TEST_DATABASE_URL is not configured';

after(async () => {
  await client?.$disconnect();
  await disconnectDatabase();
});

test('Prisma connects and creates related user, contact, conversation, and message records', { skip: skipReason }, async () => {
  assert.ok(client);
  await client.$connect();
  assert.deepEqual(await client.$queryRaw`SELECT 1`, [{ '?column?': 1 }]);

  const userId = randomUUID();
  try {
    const user = await client.user.create({
      data: {
        id: userId,
        email: `phase3b-${userId}@example.test`,
        displayName: 'Integration Test User',
        contacts: { create: { name: 'Test Contact', username: 'test.contact' } },
      },
      include: { contacts: true },
    });
    assert.equal(user.contacts.length, 1);

    const conversation = await client.conversation.create({
      data: {
        userId,
        contactId: user.contacts[0].id,
        platform: 'WHATSAPP',
        messages: {
          create: {
            content: 'Hello from the database test.',
            direction: 'INCOMING',
            status: 'DELIVERED',
          },
        },
      },
      include: { messages: true, contact: true, user: true },
    });

    assert.equal(conversation.messages.length, 1);
    assert.equal(conversation.messages[0].direction, 'INCOMING');
    assert.equal(conversation.contact.userId, conversation.user.id);

    const otherUser = await client.user.create({
      data: { email: `other-${userId}@example.test`, displayName: 'Other User' },
    });
    await assert.rejects(
      client.conversation.create({
        data: {
          userId: otherUser.id,
          contactId: user.contacts[0].id,
          platform: 'INSTAGRAM',
        },
      }),
    );
    await client.user.delete({ where: { id: otherUser.id } });
  } finally {
    await client.user.deleteMany({ where: { id: userId } });
  }
});

test('development seed can be rerun without adding duplicate sample data', { skip: skipReason }, async () => {
  assert.ok(client);
  await client.$connect();
  await seedDevelopmentData(client);
  const countsBefore = {
    user: await client.user.count({ where: { id: sampleUserId } }),
    contacts: await client.contact.count({ where: { userId: sampleUserId } }),
    conversations: await client.conversation.count({ where: { userId: sampleUserId } }),
    messages: await client.message.count({ where: { id: { in: sampleMessageIds } } }),
    preferences: await client.userPreference.count({ where: { userId: sampleUserId } }),
  };

  await seedDevelopmentData(client);
  const countsAfter = {
    user: await client.user.count({ where: { id: sampleUserId } }),
    contacts: await client.contact.count({ where: { userId: sampleUserId } }),
    conversations: await client.conversation.count({ where: { userId: sampleUserId } }),
    messages: await client.message.count({ where: { id: { in: sampleMessageIds } } }),
    preferences: await client.userPreference.count({ where: { userId: sampleUserId } }),
  };

  assert.deepEqual(countsBefore, { user: 1, contacts: 3, conversations: 3, messages: 6, preferences: 1 });
  assert.deepEqual(countsAfter, countsBefore);
});

test('database readiness endpoint verifies the configured test database', { skip: skipReason }, async () => {
  assert.ok(client);
  const response = await request(createApp()).get('/api/health/db');

  assert.equal(response.status, 200);
  assert.equal(response.body.status, 'ok');
  assert.equal(response.body.service, 'database');
});
