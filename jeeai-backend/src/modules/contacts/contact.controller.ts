import type { RequestHandler } from 'express';

import { AppError } from '../../utils/app-error.js';
import { contactIdParamsSchema, listContactsQuerySchema } from './contact.schemas.js';
import { getContactById, listContacts } from './contact.service.js';

export const getContacts: RequestHandler = async (request, response, next) => {
  const parsedQuery = listContactsQuerySchema.safeParse(request.query);
  if (!parsedQuery.success) {
    next(new AppError('Invalid contact query parameters.', 400, 'INVALID_QUERY'));
    return;
  }
  if (!request.userId) {
    next(new AppError('Request user context is unavailable.', 503, 'USER_CONTEXT_UNAVAILABLE'));
    return;
  }
  try {
    response.status(200).json(await listContacts(request.userId, parsedQuery.data));
  } catch (error) {
    next(error);
  }
};

export const getContact: RequestHandler = async (request, response, next) => {
  const parsedParams = contactIdParamsSchema.safeParse(request.params);
  if (!parsedParams.success) {
    next(new AppError('Contact ID must be a valid UUID.', 400, 'INVALID_CONTACT_ID'));
    return;
  }
  if (!request.userId) {
    next(new AppError('Request user context is unavailable.', 503, 'USER_CONTEXT_UNAVAILABLE'));
    return;
  }
  try {
    response.status(200).json(await getContactById(request.userId, parsedParams.data.id));
  } catch (error) {
    next(error);
  }
};
