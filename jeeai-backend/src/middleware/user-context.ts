import type { RequestHandler } from 'express';

import { environment } from '../config/environment.js';
import { sampleUserId } from '../database/seed-data.js';
import { AppError } from '../utils/app-error.js';

export type UserIdResolver = () => string;

export function resolveDevelopmentUserId(): string {
  if (environment.nodeEnvironment !== 'development') {
    throw new AppError(
      'Authentication is not configured for this environment.',
      503,
      'AUTHENTICATION_UNAVAILABLE',
    );
  }
  return sampleUserId;
}

export function createUserContextMiddleware(
  resolveUserId: UserIdResolver = resolveDevelopmentUserId,
): RequestHandler {
  return (request, _response, next) => {
    try {
      request.userId = resolveUserId();
      next();
    } catch (error) {
      next(error);
    }
  };
}
