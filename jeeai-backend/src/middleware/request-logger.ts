import type { RequestHandler } from 'express';

export const requestLogger: RequestHandler = (request, response, next) => {
  const startTime = process.hrtime.bigint();

  response.once('finish', () => {
    const elapsedMilliseconds =
      Number(process.hrtime.bigint() - startTime) / 1_000_000;
    console.info(
      JSON.stringify({
        level: 'info',
        method: request.method,
        path: `${request.baseUrl}${request.path}`,
        statusCode: response.statusCode,
        durationMs: Number(elapsedMilliseconds.toFixed(2)),
      }),
    );
  });

  next();
};
