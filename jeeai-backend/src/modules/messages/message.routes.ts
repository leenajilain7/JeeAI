import { Router } from 'express';

import { getMessages, postMessage } from './message.controller.js';

export const messageRouter = Router({ mergeParams: true });

messageRouter.get('/', getMessages);
messageRouter.post('/', postMessage);
