import type { RequestHandler } from 'express';

import { AppError } from '../utils/app-error.js';

export const notFoundHandler: RequestHandler = (request, _response, next) => {
  next(
    new AppError(
      `No route matches ${request.method} ${request.originalUrl}.`,
      404,
      'NOT_FOUND',
    ),
  );
};
