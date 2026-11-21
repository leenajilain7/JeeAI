import { Router } from 'express';

import { getHealth } from './health.controller.js';
import { createDatabaseHealthHandler } from './health-db.controller.js';

export function createHealthRouter(databaseProbe?: () => Promise<void>) {
  const healthRouter = Router();

  healthRouter.get('/health', getHealth);
  healthRouter.get('/health/db', createDatabaseHealthHandler(databaseProbe));
  return healthRouter;
}

export const healthRouter = createHealthRouter();
