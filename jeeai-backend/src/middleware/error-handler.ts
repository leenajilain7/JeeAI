import type { ErrorRequestHandler } from 'express';

import { AppError } from '../utils/app-error.js';
import { isDatabaseUnavailableError } from '../utils/database-error.js';

interface BodyParserError extends Error {
  type?: string;
}

function isMalformedJsonError(error: unknown): error is BodyParserError {
  return (
    error instanceof Error &&
    'type' in error &&
    (error as BodyParserError).type === 'entity.parse.failed'
  );
}

export const errorHandler: ErrorRequestHandler = (
  error: unknown,
  _request,
  response,
  next,
) => {
  if (response.headersSent) {
    next(error);
    return;
  }

  if (isMalformedJsonError(error)) {
    response.status(400).json({
      error: {
        code: 'INVALID_JSON',
        message: 'Request body must contain valid JSON.',
      },
    });
    return;
  }

  const appError = error instanceof AppError ? error : undefined;
  const databaseUnavailable = !appError && isDatabaseUnavailableError(error);
  const statusCode = appError?.statusCode ?? (databaseUnavailable ? 503 : 500);
  const code = appError?.code ?? (databaseUnavailable ? 'DATABASE_UNAVAILABLE' : 'INTERNAL_SERVER_ERROR');
  const message = appError?.message ?? (databaseUnavailable ? 'Database is unavailable.' : 'An unexpected error occurred.');

  if (statusCode >= 500 && !databaseUnavailable) {
    console.error(
      JSON.stringify({
        level: 'error',
        errorName: error instanceof Error ? error.name : 'UnknownError',
      }),
    );
  }

  response.status(statusCode).json({ error: { code, message } });
};
