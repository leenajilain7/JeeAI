import { Router } from 'express';

import { getConversation, getConversations, markConversationAsRead } from './conversation.controller.js';
import { messageRouter } from '../messages/message.routes.js';

export const conversationRouter = Router();

conversationRouter.get('/', getConversations);
conversationRouter.get('/:id', getConversation);
conversationRouter.patch('/:id/read', markConversationAsRead);
conversationRouter.use('/:id/messages', messageRouter);
