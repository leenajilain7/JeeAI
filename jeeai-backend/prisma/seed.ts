import { disconnectDatabase, getPrismaClient } from '../src/database/prisma.js';
import { seedDevelopmentData } from '../src/database/seed-data.js';

try {
  await seedDevelopmentData(getPrismaClient());
  console.info('Development sample data is ready.');
} catch {
  console.error('Could not seed development data. Check database configuration and connectivity.');
  process.exitCode = 1;
} finally {
  await disconnectDatabase();
}
