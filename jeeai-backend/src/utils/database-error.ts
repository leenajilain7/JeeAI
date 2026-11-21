interface ErrorLike {
  code?: unknown;
  errorCode?: unknown;
  errno?: unknown;
  cause?: unknown;
  message?: unknown;
}

const connectionErrorCodes = new Set([
  'ECONNREFUSED',
  'ECONNRESET',
  'ETIMEDOUT',
  'EHOSTUNREACH',
  'ENOTFOUND',
]);

export function isDatabaseUnavailableError(error: unknown): boolean {
  const visited = new Set<unknown>();
  let current: unknown = error;

  while (current && !visited.has(current)) {
    visited.add(current);
    if (typeof current !== 'object') return false;
    const errorLike = current as ErrorLike;
    const code = errorLike.code ?? errorLike.errorCode ?? errorLike.errno;
    if (
      typeof code === 'string' &&
      (connectionErrorCodes.has(code) || /^P100[0-9]$/.test(code) || /^P101[0-7]$/.test(code))
    ) {
      return true;
    }
    if (
      typeof errorLike.message === 'string' &&
      /can't reach database server|connection terminated unexpectedly|(?:DATABASE|TEST_DATABASE)_URL is required/i.test(errorLike.message)
    ) {
      return true;
    }
    current = errorLike.cause;
  }
  return false;
}
