import { z } from 'zod';

export const contactIdParamsSchema = z.object({
  id: z.string().uuid(),
});

export const listContactsQuerySchema = z.object({
  search: z.string().trim().max(100).optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export type ListContactsQuery = z.infer<typeof listContactsQuerySchema>;
