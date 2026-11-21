import 'dotenv/config';

const validNodeEnvironments = ['development', 'test', 'production'] as const;
type NodeEnvironment = (typeof validNodeEnvironments)[number];

function parsePort(value: string | undefined): number {
  if (value === undefined || value.trim() === '') return 3000;

  const port = Number(value);
  if (!Number.isInteger(port) || port < 1 || port > 65_535) {
    throw new Error('PORT must be an integer between 1 and 65535.');
  }
  return port;
}

function parseNodeEnvironment(value: string | undefined): NodeEnvironment {
  const nodeEnvironment = value ?? 'development';
  if (
    !validNodeEnvironments.includes(nodeEnvironment as NodeEnvironment)
  ) {
    throw new Error(
      `NODE_ENV must be one of: ${validNodeEnvironments.join(', ')}.`,
    );
  }
  return nodeEnvironment as NodeEnvironment;
}

export const environment = Object.freeze({
  nodeEnvironment: parseNodeEnvironment(process.env.NODE_ENV),
  port: parsePort(process.env.PORT),
  corsOrigins: (process.env.CORS_ORIGINS ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean),
});

export type AppEnvironment = typeof environment;
