import type { MessageDirection, MessageStatus } from '../../generated/prisma/client.js';
import type { PaginationMetadata } from '../contacts/contact.types.js';

export interface MessageResponse {
  id: string;
  conversationId: string;
  content: string;
  direction: MessageDirection;
  status: MessageStatus;
  createdAt: Date;
  updatedAt: Date;
}

export interface PaginatedMessages {
  data: MessageResponse[];
  pagination: PaginationMetadata;
}
