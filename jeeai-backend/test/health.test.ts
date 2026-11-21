import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';

import express from 'express';
import request from 'supertest';

import { createApp } from '../src/app.ts';
import { errorHandler } from '../src/middleware/error-handler.ts';
import { AppError } from '../src/utils/app-error.ts';

const app = createApp();
const originalInfo = console.info;

before(() => {
  console.info = () => undefined;
});

after(() => {
  console.info = originalInfo;
});

test('GET /api/health returns service status and a timestamp', async () => {
  const response = await request(app).get('/api/health');

  assert.equal(response.status, 200);
  assert.deepEqual(response.body.status, 'ok');
  assert.deepEqual(response.body.service, 'jeeai-backend');
  assert.equal(Number.isNaN(Date.parse(response.body.timestamp)), false);
});

test('database readiness returns 200 when the database probe succeeds', async () => {
  const healthyApp = createApp({ databaseProbe: async () => undefined });
  const response = await request(healthyApp).get('/api/health/db');

  assert.equal(response.status, 200);
  assert.equal(response.body.service, 'database');
  assert.equal(response.body.status, 'ok');
});

test('database readiness returns a generic 503 when the database probe fails', async () => {
  const unavailableApp = createApp({
    databaseProbe: async () => {
      throw new Error('postgresql://private-user:secret@host/db');
    },
  });
  const response = await request(unavailableApp).get('/api/health/db');

  assert.equal(response.status, 503);
  assert.equal(response.body.status, 'unavailable');
  assert.equal(JSON.stringify(response.body).includes('secret'), false);
});

test('unknown API routes return a structured 404 response', async () => {
  const response = await request(app).get('/api/does-not-exist');

  assert.equal(response.status, 404);
  assert.deepEqual(response.body.error.code, 'NOT_FOUND');
});

test('malformed JSON is rejected with HTTP 400', async () => {
  const response = await request(app)
    .post('/api/health')
    .set('Content-Type', 'application/json')
    .send('{');

  assert.equal(response.status, 400);
  assert.deepEqual(response.body.error.code, 'INVALID_JSON');
});

test('central error middleware returns known errors without exposing stack details', async () => {
  const errorTestApp = express();
  errorTestApp.get('/failure', (_request, _response, next) => {
    next(new AppError('A controlled test failure.', 422, 'TEST_FAILURE'));
  });
  errorTestApp.use(errorHandler);

  const response = await request(errorTestApp).get('/failure');

  assert.equal(response.status, 422);
  assert.deepEqual(response.body, {
    error: {
      code: 'TEST_FAILURE',
      message: 'A controlled test failure.',
    },
  });
});

test('unexpected errors return a generic HTTP 500 response', async () => {
  const errorTestApp = express();
  const originalError = console.error;
  console.error = () => undefined;
  errorTestApp.get('/failure', (_request, _response, next) => {
    next(new Error('Private implementation detail.'));
  });
  errorTestApp.use(errorHandler);

  try {
    const response = await request(errorTestApp).get('/failure');

    assert.equal(response.status, 500);
    assert.deepEqual(response.body, {
      error: {
        code: 'INTERNAL_SERVER_ERROR',
        message: 'An unexpected error occurred.',
      },
    });
    assert.equal(JSON.stringify(response.body).includes('Private'), false);
  } finally {
    console.error = originalError;
  }
});

test('database connection errors return a generic service-unavailable response', async () => {
  const databaseErrorApp = express();
  databaseErrorApp.get('/database-failure', (_request, _response, next) => {
    next(Object.assign(new Error('Connection failed for postgresql://private:secret@host/db'), { code: 'P1001' }));
  });
  databaseErrorApp.use(errorHandler);

  const response = await request(databaseErrorApp).get('/database-failure');

  assert.equal(response.status, 503);
  assert.deepEqual(response.body, {
    error: { code: 'DATABASE_UNAVAILABLE', message: 'Database is unavailable.' },
  });
  assert.equal(JSON.stringify(response.body).includes('secret'), false);
});

test('API documentation is available as JSON and Swagger UI', async () => {
  const jsonResponse = await request(app).get('/api/openapi.json');
  const docsResponse = await request(app).get('/api/docs/');

  assert.equal(jsonResponse.status, 200);
  assert.deepEqual(jsonResponse.body.openapi, '3.1.0');
  assert.equal(docsResponse.status, 200);
  assert.ok(jsonResponse.body.paths['/contacts']);
  assert.ok(jsonResponse.body.paths['/conversations/{id}/messages']);
});
