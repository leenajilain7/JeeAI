import { Router } from 'express';

import { getContact, getContacts } from './contact.controller.js';

export const contactRouter = Router();

contactRouter.get('/', getContacts);
contactRouter.get('/:id', getContact);
