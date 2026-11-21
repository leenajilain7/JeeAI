import { getPrismaClient } from '../../database/prisma.js';
import { AppError } from '../../utils/app-error.js';
import type { ListContactsQuery } from './contact.schemas.js';
import type { ContactResponse, PaginatedResponse } from './contact.types.js';

export async function listContacts(
  userId: string,
  query: ListContactsQuery,
): Promise<PaginatedResponse<ContactResponse>> {
  const prisma = getPrismaClient();
  const where = {
    userId,
    ...(query.search ? { name: { contains: query.search, mode: 'insensitive' as const } } : {}),
  };
  const [data, total] = await prisma.$transaction([
    prisma.contact.findMany({
      where,
      orderBy: [{ name: 'asc' }, { id: 'asc' }],
      skip: (query.page - 1) * query.limit,
      take: query.limit,
      select: {
        id: true,
        name: true,
        username: true,
        profileImage: true,
        createdAt: true,
        updatedAt: true,
      },
    }),
    prisma.contact.count({ where }),
  ]);

  return {
    data,
    pagination: {
      page: query.page,
      limit: query.limit,
      total,
      totalPages: Math.ceil(total / query.limit),
    },
  };
}

export async function getContactById(userId: string, id: string): Promise<ContactResponse> {
  const contact = await getPrismaClient().contact.findFirst({
    where: { id, userId },
    select: {
      id: true,
      name: true,
      username: true,
      profileImage: true,
      createdAt: true,
      updatedAt: true,
    },
  });
  if (!contact) throw new AppError('Contact not found.', 404, 'CONTACT_NOT_FOUND');
  return contact;
}
