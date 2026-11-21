const jsonContent = (schema: Record<string, unknown>) => ({
  'application/json': { schema },
});

const errorResponse = (description: string) => ({
  description,
  content: jsonContent({ $ref: '#/components/schemas/ErrorResponse' }),
});

const paginationQuery = (defaultLimit = 20) => [
  { name: 'page', in: 'query', description: 'One-based page number.', schema: { type: 'integer', minimum: 1, default: 1 } },
  { name: 'limit', in: 'query', description: 'Items per page (maximum 100).', schema: { type: 'integer', minimum: 1, maximum: 100, default: defaultLimit } },
];

const idParameter = {
  name: 'id',
  in: 'path',
  required: true,
  description: 'Resource UUID.',
  schema: { type: 'string', format: 'uuid' },
};

const paginatedResponse = (description: string, itemSchema: string) => ({
  description,
  content: jsonContent({
    type: 'object',
    required: ['data', 'pagination'],
    properties: {
      data: { type: 'array', items: { $ref: `#/components/schemas/${itemSchema}` } },
      pagination: { $ref: '#/components/schemas/Pagination' },
    },
  }),
});

export const openApiDocument = {
  openapi: '3.1.0',
  info: {
    title: 'JeeAI API',
    version: '1.0.0',
    description: 'Development REST API. Data endpoints use the seeded development user and fail closed outside development until authentication is implemented.',
  },
  servers: [{ url: '/api', description: 'JeeAI API' }],
  paths: {
    '/health': {
      get: {
        summary: 'Check API health',
        operationId: 'getHealth',
        responses: {
          '200': { description: 'The API is healthy.' },
          default: errorResponse('Unexpected server error.'),
        },
      },
    },
    '/health/db': {
      get: {
        summary: 'Check PostgreSQL readiness',
        operationId: 'getDatabaseHealth',
        responses: {
          '200': { description: 'PostgreSQL is accepting queries.' },
          '503': {
            description: 'PostgreSQL is unavailable.',
            content: jsonContent({
              type: 'object',
              required: ['status', 'service', 'message', 'timestamp'],
              properties: {
                status: { type: 'string', enum: ['unavailable'] },
                service: { type: 'string', enum: ['database'] },
                message: { type: 'string' },
                timestamp: { type: 'string', format: 'date-time' },
              },
            }),
          },
          default: errorResponse('Unexpected server error.'),
        },
      },
    },
    '/contacts': {
      get: {
        summary: 'List contacts',
        description: 'Returns contacts belonging to the resolved user. Search matches contact names without case sensitivity.',
        operationId: 'listContacts',
        parameters: [
          { name: 'search', in: 'query', description: 'Optional contact-name search.', schema: { type: 'string', maxLength: 100 } },
          ...paginationQuery(),
        ],
        responses: {
          '200': paginatedResponse('Paginated contacts.', 'Contact'),
          '400': errorResponse('Invalid search or pagination parameters.'),
          '503': errorResponse('Database or authentication context is unavailable.'),
          default: errorResponse('Unexpected server error.'),
        },
      },
    },
    '/contacts/{id}': {
      get: {
        summary: 'Get a contact',
        description: 'Returns a contact only when it belongs to the resolved user.',
        operationId: 'getContact',
        parameters: [idParameter],
        responses: {
          '200': { description: 'Contact details.', content: jsonContent({ $ref: '#/components/schemas/Contact' }) },
          '400': errorResponse('The contact ID is not a valid UUID.'),
          '404': errorResponse('The contact does not exist for this user.'),
          '503': errorResponse('Database or authentication context is unavailable.'),
          default: errorResponse('Unexpected server error.'),
        },
      },
    },
    '/conversations': {
      get: {
        summary: 'List conversations',
        description: 'Returns conversations by latest activity, including contact details, latest message preview, and unread count.',
        operationId: 'listConversations',
        parameters: [
          { name: 'platform', in: 'query', schema: { type: 'string', enum: ['WHATSAPP', 'INSTAGRAM', 'FACEBOOK_MESSENGER'] } },
          { name: 'search', in: 'query', description: 'Optional contact-name search.', schema: { type: 'string', maxLength: 100 } },
          ...paginationQuery(),
        ],
        responses: {
          '200': paginatedResponse('Paginated conversations.', 'Conversation'),
          '400': errorResponse('Invalid platform, search, or pagination parameter.'),
          '503': errorResponse('Database or authentication context is unavailable.'),
          default: errorResponse('Unexpected server error.'),
        },
      },
    },
    '/conversations/{id}': {
      get: {
        summary: 'Get a conversation',
        operationId: 'getConversation',
        parameters: [idParameter],
        responses: {
          '200': { description: 'Conversation details.', content: jsonContent({ $ref: '#/components/schemas/Conversation' }) },
          '400': errorResponse('The conversation ID is not a valid UUID.'),
          '404': errorResponse('The conversation does not exist for this user.'),
          '503': errorResponse('Database or authentication context is unavailable.'),
          default: errorResponse('Unexpected server error.'),
        },
      },
    },
    '/conversations/{id}/read': {
      patch: {
        summary: 'Mark a conversation as read',
        operationId: 'markConversationRead',
        parameters: [idParameter],
        responses: {
          '200': {
            description: 'Unread count cleared.',
            content: jsonContent({
              type: 'object',
              required: ['id', 'unreadCount', 'updatedAt'],
              properties: {
                id: { type: 'string', format: 'uuid' },
                unreadCount: { type: 'integer', example: 0 },
                updatedAt: { type: 'string', format: 'date-time' },
              },
            }),
          },
          '400': errorResponse('The conversation ID is not a valid UUID.'),
          '404': errorResponse('The conversation does not exist for this user.'),
          '503': errorResponse('Database or authentication context is unavailable.'),
          default: errorResponse('Unexpected server error.'),
        },
      },
    },
    '/conversations/{id}/messages': {
      get: {
        summary: 'List conversation messages',
        description: 'Returns messages in chronological order, scoped to a conversation owned by the resolved user.',
        operationId: 'listMessages',
        parameters: [idParameter, ...paginationQuery(50)],
        responses: {
          '200': paginatedResponse('Paginated messages.', 'Message'),
          '400': errorResponse('Invalid conversation ID or pagination parameter.'),
          '404': errorResponse('The conversation does not exist for this user.'),
          '503': errorResponse('Database or authentication context is unavailable.'),
          default: errorResponse('Unexpected server error.'),
        },
      },
      post: {
        summary: 'Create a simulated outgoing message',
        description: 'Stores an outgoing message locally and updates conversation activity. No social platform is contacted.',
        operationId: 'createOutgoingMessage',
        parameters: [idParameter],
        requestBody: {
          required: true,
          content: jsonContent({
            type: 'object',
            required: ['content'],
            additionalProperties: false,
            properties: { content: { type: 'string', minLength: 1, maxLength: 10_000 } },
          }),
        },
        responses: {
          '201': { description: 'Outgoing message stored.', content: jsonContent({ $ref: '#/components/schemas/Message' }) },
          '400': errorResponse('Invalid conversation ID or message content.'),
          '404': errorResponse('The conversation does not exist for this user.'),
          '503': errorResponse('Database or authentication context is unavailable.'),
        },
      },
    },
  },
  components: {
    schemas: {
      ErrorResponse: {
        type: 'object',
        required: ['error'],
        properties: {
          error: {
            type: 'object',
            required: ['code', 'message'],
            properties: { code: { type: 'string' }, message: { type: 'string' } },
          },
        },
      },
      Pagination: {
        type: 'object',
        required: ['page', 'limit', 'total', 'totalPages'],
        properties: {
          page: { type: 'integer', minimum: 1 },
          limit: { type: 'integer', minimum: 1, maximum: 100 },
          total: { type: 'integer', minimum: 0 },
          totalPages: { type: 'integer', minimum: 0 },
        },
      },
      Contact: {
        type: 'object',
        required: ['id', 'name', 'username', 'profileImage', 'createdAt', 'updatedAt'],
        properties: {
          id: { type: 'string', format: 'uuid' },
          name: { type: 'string' },
          username: { type: ['string', 'null'] },
          profileImage: { type: ['string', 'null'] },
          createdAt: { type: 'string', format: 'date-time' },
          updatedAt: { type: 'string', format: 'date-time' },
        },
      },
      Message: {
        type: 'object',
        required: ['id', 'conversationId', 'content', 'direction', 'status', 'createdAt', 'updatedAt'],
        properties: {
          id: { type: 'string', format: 'uuid' },
          conversationId: { type: 'string', format: 'uuid' },
          content: { type: 'string' },
          direction: { type: 'string', enum: ['INCOMING', 'OUTGOING'] },
          status: { type: 'string', enum: ['SENDING', 'SENT', 'DELIVERED', 'READ', 'FAILED'] },
          createdAt: { type: 'string', format: 'date-time' },
          updatedAt: { type: 'string', format: 'date-time' },
        },
      },
      LatestMessagePreview: {
        type: 'object',
        required: ['id', 'content', 'direction', 'status', 'createdAt'],
        properties: {
          id: { type: 'string', format: 'uuid' },
          content: { type: 'string' },
          direction: { type: 'string', enum: ['INCOMING', 'OUTGOING'] },
          status: { type: 'string', enum: ['SENDING', 'SENT', 'DELIVERED', 'READ', 'FAILED'] },
          createdAt: { type: 'string', format: 'date-time' },
        },
      },
      Conversation: {
        type: 'object',
        required: ['id', 'platform', 'lastMessageAt', 'unreadCount', 'contact', 'latestMessage'],
        properties: {
          id: { type: 'string', format: 'uuid' },
          platform: { type: 'string', enum: ['WHATSAPP', 'INSTAGRAM', 'FACEBOOK_MESSENGER'] },
          lastMessageAt: { type: ['string', 'null'], format: 'date-time' },
          unreadCount: { type: 'integer', minimum: 0 },
          contact: { $ref: '#/components/schemas/Contact' },
          latestMessage: { oneOf: [{ $ref: '#/components/schemas/LatestMessagePreview' }, { type: 'null' }] },
        },
      },
    },
  },
} as const;
