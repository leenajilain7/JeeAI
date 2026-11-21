import express from 'express';
import swaggerUi from 'swagger-ui-express';

import { openApiDocument } from './config/openapi.js';
import { corsPolicy } from './middleware/cors-policy.js';
import { errorHandler } from './middleware/error-handler.js';
import { notFoundHandler } from './middleware/not-found-handler.js';
import { requestLogger } from './middleware/request-logger.js';
import type { UserIdResolver } from './middleware/user-context.js';
import { createApiRouter } from './routes/api.routes.js';

export function createApp(options: {
  databaseProbe?: () => Promise<void>;
  userIdResolver?: UserIdResolver;
} = {}) {
  const app = express();

  app.disable('x-powered-by');
  app.use(requestLogger);
  app.use(corsPolicy);
  app.use(express.json({ limit: '1mb' }));

  app.get('/api/openapi.json', (_request, response) => {
    response.status(200).json(openApiDocument);
  });
  app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(openApiDocument));
  app.use('/api', createApiRouter(options));

  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}
