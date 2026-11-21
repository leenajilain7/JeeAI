import type { RequestHandler } from 'express';

import { checkDatabaseConnection } from '../../database/prisma.js';

export function createDatabaseHealthHandler(
  probe: () => Promise<void> = checkDatabaseConnection,
): RequestHandler {
  return async (_request, response) => {
    try {
      await probe();
      response.status(200).json({
        status: 'ok',
        service: 'database',
        timestamp: new Date().toISOString(),
      });
    } catch {
      response.status(503).json({
        status: 'unavailable',
        service: 'database',
        message: 'Database is unavailable.',
        timestamp: new Date().toISOString(),
      });
    }
  };
}
