import { z } from 'zod';

export const conversationMessagesParamsSchema = z.object({
  id: z.string().uuid(),
});

export const listMessagesQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(50),
});

export const createMessageBodySchema = z.object({
  content: z.string().trim().min(1).max(10_000),
});

export type ListMessagesQuery = z.infer<typeof listMessagesQuerySchema>;
export type CreateMessageBody = z.infer<typeof createMessageBodySchema>;
