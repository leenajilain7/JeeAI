import { PrismaPg } from '@prisma/adapter-pg';

import { PrismaClient } from '../generated/prisma/client.js';

let prisma: PrismaClient | undefined;

function connectionString(): string {
  const variable = process.env.NODE_ENV === 'test' ? 'TEST_DATABASE_URL' : 'DATABASE_URL';
  const value = process.env[variable];
  if (!value) {
    throw new Error(`${variable} is required to connect to PostgreSQL.`);
  }
  return value;
}

export function createPrismaClient(url: string): PrismaClient {
  return new PrismaClient({ adapter: new PrismaPg({ connectionString: url }) });
}

export function getPrismaClient(): PrismaClient {
  prisma ??= createPrismaClient(connectionString());
  return prisma;
}

export async function connectDatabase(): Promise<void> {
  await getPrismaClient().$connect();
}

export async function checkDatabaseConnection(): Promise<void> {
  await getPrismaClient().$queryRaw`SELECT 1`;
}

export async function disconnectDatabase(): Promise<void> {
  if (prisma) {
    const client = prisma;
    prisma = undefined;
    await client.$disconnect();
  }
}
