import { createApp } from './app.js';
import { environment } from './config/environment.js';
import { disconnectDatabase } from './database/prisma.js';

const app = createApp();
const server = app.listen(environment.port, () => {
  console.info(`JeeAI API listening on http://localhost:${environment.port}`);
  console.info(`API docs: http://localhost:${environment.port}/api/docs`);
});

function shutDown(signal: string): void {
  console.info(`${signal} received; closing the HTTP server.`);
  server.close((error) => {
    if (error) {
      console.error('Error while closing the HTTP server.', error);
      process.exitCode = 1;
    }
    void disconnectDatabase().catch(() => {
      console.error('Error while closing the database connection.');
      process.exitCode = 1;
    });
  });
}

process.once('SIGINT', () => shutDown('SIGINT'));
process.once('SIGTERM', () => shutDown('SIGTERM'));
