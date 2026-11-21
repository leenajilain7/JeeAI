import { Router } from 'express';

import { contactRouter } from '../modules/contacts/contact.routes.js';
import { conversationRouter } from '../modules/conversations/conversation.routes.js';
import { createHealthRouter } from '../modules/health/health.routes.js';
import { createUserContextMiddleware, type UserIdResolver } from '../middleware/user-context.js';

export function createApiRouter(options: {
  databaseProbe?: () => Promise<void>;
  userIdResolver?: UserIdResolver;
} = {}) {
  const apiRouter = Router();

  apiRouter.use(createHealthRouter(options.databaseProbe));
  apiRouter.use(
    '/contacts',
    createUserContextMiddleware(options.userIdResolver),
    contactRouter,
  );
  apiRouter.use(
    '/conversations',
    createUserContextMiddleware(options.userIdResolver),
    conversationRouter,
  );
  return apiRouter;
}

export const apiRouter = createApiRouter();
