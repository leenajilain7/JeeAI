import { getPrismaClient } from '../../database/prisma.js';
import type { MessageDirection, MessageStatus } from '../../generated/prisma/client.js';
import { AppError } from '../../utils/app-error.js';
import type { ListConversationsQuery } from './conversation.schemas.js';
import type { ConversationSummary, PaginatedConversations } from './conversation.types.js';

const conversationSelect = {
  id: true,
  platform: true,
  lastMessageAt: true,
  unreadCount: true,
  contact: { select: { id: true, name: true, username: true, profileImage: true } },
  messages: {
    orderBy: { createdAt: 'desc' as const },
    take: 1,
    select: { id: true, content: true, direction: true, status: true, createdAt: true },
  },
};

type LatestMessage = {
  id: string;
  content: string;
  direction: MessageDirection;
  status: MessageStatus;
  createdAt: Date;
};

function withLatestMessage<T extends { messages: LatestMessage[] }>(
  conversation: T,
): Omit<T, 'messages'> & { latestMessage: LatestMessage | null } {
  const { messages, ...fields } = conversation;
  return { ...fields, latestMessage: messages[0] ?? null };
}

export async function listConversations(
  userId: string,
  query: ListConversationsQuery,
): Promise<PaginatedConversations> {
  const prisma = getPrismaClient();
  const where = {
    userId,
    ...(query.platform ? { platform: query.platform } : {}),
    ...(query.search
      ? { contact: { name: { contains: query.search, mode: 'insensitive' as const } } }
      : {}),
  };
  const [conversations, total] = await prisma.$transaction([
    prisma.conversation.findMany({
      where,
      select: conversationSelect,
      orderBy: [{ lastMessageAt: { sort: 'desc', nulls: 'last' } }, { id: 'asc' }],
      skip: (query.page - 1) * query.limit,
      take: query.limit,
    }),
    prisma.conversation.count({ where }),
  ]);

  return {
    data: conversations.map(withLatestMessage),
    pagination: {
      page: query.page,
      limit: query.limit,
      total,
      totalPages: Math.ceil(total / query.limit),
    },
  };
}

export async function getConversationById(userId: string, id: string): Promise<ConversationSummary> {
  const conversation = await getPrismaClient().conversation.findFirst({
    where: { id, userId },
    select: conversationSelect,
  });
  if (!conversation) {
    throw new AppError('Conversation not found.', 404, 'CONVERSATION_NOT_FOUND');
  }
  return withLatestMessage(conversation);
}

export async function markConversationRead(userId: string, id: string) {
  return getPrismaClient().$transaction(async (transaction) => {
    const updateResult = await transaction.conversation.updateMany({
      where: { id, userId },
      data: { unreadCount: 0 },
    });
    if (updateResult.count === 0) {
      throw new AppError('Conversation not found.', 404, 'CONVERSATION_NOT_FOUND');
    }
    return transaction.conversation.findFirstOrThrow({
      where: { id, userId },
      select: { id: true, unreadCount: true, updatedAt: true },
    });
  });
}
