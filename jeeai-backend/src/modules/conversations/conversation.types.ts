import type { MessageDirection, MessageStatus, Platform } from '../../generated/prisma/client.js';
import type { PaginationMetadata } from '../contacts/contact.types.js';

export interface ConversationSummary {
  id: string;
  platform: Platform;
  lastMessageAt: Date | null;
  unreadCount: number;
  contact: {
    id: string;
    name: string;
    username: string | null;
    profileImage: string | null;
  };
  latestMessage: {
    id: string;
    content: string;
    direction: MessageDirection;
    status: MessageStatus;
    createdAt: Date;
  } | null;
}

export interface PaginatedConversations {
  data: ConversationSummary[];
  pagination: PaginationMetadata;
}
