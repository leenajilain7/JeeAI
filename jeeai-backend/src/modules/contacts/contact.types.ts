export interface PaginationMetadata {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: PaginationMetadata;
}

export interface ContactResponse {
  id: string;
  name: string;
  username: string | null;
  profileImage: string | null;
  createdAt: Date;
  updatedAt: Date;
}
