import type { RequestHandler } from 'express';

import { AppError } from '../../utils/app-error.js';
import { conversationIdParamsSchema, listConversationsQuerySchema } from './conversation.schemas.js';
import { getConversationById, listConversations, markConversationRead } from './conversation.service.js';

function requireUserId(request: Parameters<RequestHandler>[0], next: Parameters<RequestHandler>[2]) {
  if (request.userId) return request.userId;
  next(new AppError('Request user context is unavailable.', 503, 'USER_CONTEXT_UNAVAILABLE'));
  return undefined;
}

export const getConversations: RequestHandler = async (request, response, next) => {
  const parsedQuery = listConversationsQuerySchema.safeParse(request.query);
  if (!parsedQuery.success) {
    next(new AppError('Invalid conversation query parameters.', 400, 'INVALID_QUERY'));
    return;
  }
  const userId = requireUserId(request, next);
  if (!userId) return;
  try {
    response.status(200).json(await listConversations(userId, parsedQuery.data));
  } catch (error) {
    next(error);
  }
};

export const getConversation: RequestHandler = async (request, response, next) => {
  const parsedParams = conversationIdParamsSchema.safeParse(request.params);
  if (!parsedParams.success) {
    next(new AppError('Conversation ID must be a valid UUID.', 400, 'INVALID_CONVERSATION_ID'));
    return;
  }
  const userId = requireUserId(request, next);
  if (!userId) return;
  try {
    response.status(200).json(await getConversationById(userId, parsedParams.data.id));
  } catch (error) {
    next(error);
  }
};

export const markConversationAsRead: RequestHandler = async (request, response, next) => {
  const parsedParams = conversationIdParamsSchema.safeParse(request.params);
  if (!parsedParams.success) {
    next(new AppError('Conversation ID must be a valid UUID.', 400, 'INVALID_CONVERSATION_ID'));
    return;
  }
  const userId = requireUserId(request, next);
  if (!userId) return;
  try {
    response.status(200).json(await markConversationRead(userId, parsedParams.data.id));
  } catch (error) {
    next(error);
  }
};
