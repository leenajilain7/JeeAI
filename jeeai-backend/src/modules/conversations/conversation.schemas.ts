import { z } from 'zod';

export const conversationIdParamsSchema = z.object({
  id: z.string().uuid(),
});

export const platformSchema = z.enum(['WHATSAPP', 'INSTAGRAM', 'FACEBOOK_MESSENGER']);

export const listConversationsQuerySchema = z.object({
  platform: platformSchema.optional(),
  search: z.string().trim().max(100).optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

export type ListConversationsQuery = z.infer<typeof listConversationsQuerySchema>;
