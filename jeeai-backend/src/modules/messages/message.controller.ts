import type { RequestHandler } from 'express';

import { AppError } from '../../utils/app-error.js';
import { conversationMessagesParamsSchema, createMessageBodySchema, listMessagesQuerySchema } from './message.schemas.js';
import { createOutgoingMessage, listMessages } from './message.service.js';

function requireUserId(request: Parameters<RequestHandler>[0], next: Parameters<RequestHandler>[2]) {
  if (request.userId) return request.userId;
  next(new AppError('Request user context is unavailable.', 503, 'USER_CONTEXT_UNAVAILABLE'));
  return undefined;
}

export const getMessages: RequestHandler = async (request, response, next) => {
  const parsedParams = conversationMessagesParamsSchema.safeParse(request.params);
  const parsedQuery = listMessagesQuerySchema.safeParse(request.query);
  if (!parsedParams.success) {
    next(new AppError('Conversation ID must be a valid UUID.', 400, 'INVALID_CONVERSATION_ID'));
    return;
  }
  if (!parsedQuery.success) {
    next(new AppError('Invalid message query parameters.', 400, 'INVALID_QUERY'));
    return;
  }
  const userId = requireUserId(request, next);
  if (!userId) return;
  try {
    response.status(200).json(
      await listMessages(userId, parsedParams.data.id, parsedQuery.data),
    );
  } catch (error) {
    next(error);
  }
};

export const postMessage: RequestHandler = async (request, response, next) => {
  const parsedParams = conversationMessagesParamsSchema.safeParse(request.params);
  const parsedBody = createMessageBodySchema.safeParse(request.body);
  if (!parsedParams.success) {
    next(new AppError('Conversation ID must be a valid UUID.', 400, 'INVALID_CONVERSATION_ID'));
    return;
  }
  if (!parsedBody.success) {
    next(new AppError('Message content must be between 1 and 10000 characters.', 400, 'INVALID_MESSAGE'));
    return;
  }
  const userId = requireUserId(request, next);
  if (!userId) return;
  try {
    const message = await createOutgoingMessage(
      userId,
      parsedParams.data.id,
      parsedBody.data,
    );
    response.status(201).json(message);
  } catch (error) {
    next(error);
  }
};
