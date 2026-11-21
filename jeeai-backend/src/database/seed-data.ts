import type { PrismaClient } from '../generated/prisma/client.js';

export const sampleUserId = '2d8c4620-18d3-4bf8-93a1-8a9cb75f0001';

const contacts = [
  { id: '2d8c4620-18d3-4bf8-93a1-8a9cb75f0002', name: 'Maya Perera', username: 'maya.p', platform: 'WHATSAPP' as const },
  { id: '2d8c4620-18d3-4bf8-93a1-8a9cb75f0003', name: 'Noah Silva', username: 'noah.creates', platform: 'INSTAGRAM' as const },
  { id: '2d8c4620-18d3-4bf8-93a1-8a9cb75f0004', name: 'Amara Fernando', username: 'amara.fernando', platform: 'FACEBOOK_MESSENGER' as const },
];

const fixtures = [
  { id: '2d8c4620-18d3-4bf8-93a1-8a9cb75f0011', messageIds: ['2d8c4620-18d3-4bf8-93a1-8a9cb75f0101', '2d8c4620-18d3-4bf8-93a1-8a9cb75f0102'], contactId: contacts[0].id, platform: contacts[0].platform, unreadCount: 1, content: ['Are we still meeting for coffee tomorrow?', 'Yes, looking forward to it!'] },
  { id: '2d8c4620-18d3-4bf8-93a1-8a9cb75f0012', messageIds: ['2d8c4620-18d3-4bf8-93a1-8a9cb75f0103', '2d8c4620-18d3-4bf8-93a1-8a9cb75f0104'], contactId: contacts[1].id, platform: contacts[1].platform, unreadCount: 2, content: ['Loved the photos from the trip!', 'Thanks! I will share the rest soon.'] },
  { id: '2d8c4620-18d3-4bf8-93a1-8a9cb75f0013', messageIds: ['2d8c4620-18d3-4bf8-93a1-8a9cb75f0105', '2d8c4620-18d3-4bf8-93a1-8a9cb75f0106'], contactId: contacts[2].id, platform: contacts[2].platform, unreadCount: 0, content: ['Could you send me the recipe?', 'Of course, I will send it tonight.'] },
];

export const sampleMessageIds = fixtures.flatMap((fixture) => fixture.messageIds);

/** Idempotently create fictional local development fixtures. */
export async function seedDevelopmentData(client: PrismaClient): Promise<void> {
  await client.user.upsert({
    where: { id: sampleUserId },
    update: { email: 'dev@jeeai.example', displayName: 'JeeAI Demo User' },
    create: { id: sampleUserId, email: 'dev@jeeai.example', displayName: 'JeeAI Demo User' },
  });

  for (const contact of contacts) {
    const { platform: _platform, ...contactData } = contact;
    await client.contact.upsert({
      where: { id: contact.id },
      update: { userId: sampleUserId, name: contact.name, username: contact.username },
      create: { ...contactData, userId: sampleUserId },
    });
  }

  for (const fixture of fixtures) {
    const conversation = await client.conversation.upsert({
      where: { id: fixture.id },
      update: { userId: sampleUserId, contactId: fixture.contactId, platform: fixture.platform, unreadCount: fixture.unreadCount },
      create: { id: fixture.id, userId: sampleUserId, contactId: fixture.contactId, platform: fixture.platform, unreadCount: fixture.unreadCount },
    });
    for (const [index, content] of fixture.content.entries()) {
      await client.message.upsert({
        where: { id: fixture.messageIds[index] },
        update: { conversationId: conversation.id, content, direction: index === 0 ? 'INCOMING' : 'OUTGOING', status: index === 0 ? 'READ' : 'SENT' },
        create: { id: fixture.messageIds[index], conversationId: conversation.id, content, direction: index === 0 ? 'INCOMING' : 'OUTGOING', status: index === 0 ? 'READ' : 'SENT' },
      });
    }
  }

  await client.userPreference.upsert({
    where: { userId: sampleUserId },
    update: { preferredLanguage: 'en', responseTone: 'friendly', emojiPreference: true, personalInstructions: null },
    create: { userId: sampleUserId, preferredLanguage: 'en', responseTone: 'friendly', emojiPreference: true },
  });
}
