import cors from 'cors';

import { environment } from '../config/environment.js';
import { AppError } from '../utils/app-error.js';

function isDevelopmentLoopbackOrigin(origin: string): boolean {
  try {
    const parsedOrigin = new URL(origin);
    const isLoopbackHost = ['localhost', '127.0.0.1', '[::1]'].includes(
      parsedOrigin.hostname,
    );
    return parsedOrigin.protocol === 'http:' && isLoopbackHost;
  } catch {
    return false;
  }
}

export const corsPolicy = cors({
  origin(origin, callback) {
    // Native apps and command-line clients do not send an Origin header.
    if (!origin) {
      callback(null, true);
      return;
    }

    const isConfiguredOrigin = environment.corsOrigins.includes(origin);
    const isAllowedDevelopmentOrigin =
      environment.nodeEnvironment === 'development' &&
      isDevelopmentLoopbackOrigin(origin);

    if (isConfiguredOrigin || isAllowedDevelopmentOrigin) {
      callback(null, true);
      return;
    }

    callback(
      new AppError('This origin is not allowed by the CORS policy.', 403, 'CORS_ORIGIN_DENIED'),
    );
  },
  methods: ['GET', 'HEAD', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  optionsSuccessStatus: 204,
});
