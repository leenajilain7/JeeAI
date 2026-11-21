import { getPrismaClient } from '../../database/prisma.js';
import { AppError } from '../../utils/app-error.js';
import type { CreateMessageBody, ListMessagesQuery } from './message.schemas.js';
import type { MessageResponse, PaginatedMessages } from './message.types.js';

export async function listMessages(
  userId: string,
  conversationId: string,
  query: ListMessagesQuery,
): Promise<PaginatedMessages> {
  const prisma = getPrismaClient();
  const conversation = await prisma.conversation.findFirst({
    where: { id: conversationId, userId },
    select: { id: true },
  });
  if (!conversation) {
    throw new AppError('Conversation not found.', 404, 'CONVERSATION_NOT_FOUND');
  }

  const where = { conversationId, conversation: { userId } };
  const [data, total] = await prisma.$transaction([
    prisma.message.findMany({
      where,
      orderBy: [{ createdAt: 'asc' }, { id: 'asc' }],
      skip: (query.page - 1) * query.limit,
      take: query.limit,
      select: {
        id: true,
        conversationId: true,
        content: true,
        direction: true,
        status: true,
        createdAt: true,
        updatedAt: true,
      },
    }),
    prisma.message.count({ where }),
  ]);
  return {
    data,
    pagination: {
      page: query.page,
      limit: query.limit,
      total,
      totalPages: Math.ceil(total / query.limit),
    },
  };
}

export async function createOutgoingMessage(
  userId: string,
  conversationId: string,
  input: CreateMessageBody,
): Promise<MessageResponse> {
  return getPrismaClient().$transaction(async (transaction) => {
    const conversation = await transaction.conversation.findFirst({
      where: { id: conversationId, userId },
      select: { id: true },
    });
    if (!conversation) {
      throw new AppError('Conversation not found.', 404, 'CONVERSATION_NOT_FOUND');
    }

    const createdAt = new Date();
    const message = await transaction.message.create({
      data: {
        conversationId: conversation.id,
        content: input.content,
        direction: 'OUTGOING',
        status: 'SENT',
        createdAt,
      },
      select: {
        id: true,
        conversationId: true,
        content: true,
        direction: true,
        status: true,
        createdAt: true,
        updatedAt: true,
      },
    });
    await transaction.conversation.update({
      where: { id: conversation.id },
      data: { lastMessageAt: message.createdAt },
    });
    return message;
  });
}
