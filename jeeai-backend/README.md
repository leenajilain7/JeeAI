# JeeAI Backend

The JeeAI backend provides an Express API, PostgreSQL persistence through Prisma,
health checks, and OpenAPI documentation. This phase adds read APIs for contacts
and conversations plus local-only simulated outgoing messages. Authentication,
AI APIs, social platform integrations, and Flutter API integration are not
included yet.

## Requirements

- Node.js 20.19 or newer (Node.js 24 LTS is recommended for new development).
- npm 10 or newer.

## Setup

```sh
cd jeeai-backend
npm install
```

Create `.env` from `.env.example` only if you do not already have one. If a
`.env` already exists, keep it and add the database variables shown in the
example. Set a local `POSTGRES_PASSWORD`, and make sure `DATABASE_URL` uses the
same local PostgreSQL username, password, host, port, and database.

When Docker is available, start the local development database:

```sh
docker compose up -d postgres
```

Then apply the checked-in migration and load the fictional development fixtures:

```sh
npm run db:migrate:deploy
npm run db:seed
npm run dev
```

The development server listens on `http://localhost:3000` by default and
restarts when source files change.

## Check the service

In another terminal:

```sh
curl -i http://localhost:3000/api/health
```

The endpoint returns HTTP `200` with JSON similar to:

```json
{
  "status": "ok",
  "service": "jeeai-backend",
  "timestamp": "2026-11-20T10:42:00.000Z"
}
```

`GET /api/health/db` performs a live PostgreSQL readiness check. It returns
HTTP `200` when connected and HTTP `503` with a generic message when unavailable.
Neither endpoint returns database connection details. The API starts even when
PostgreSQL is unavailable, so `/api/health` remains usable during database
outages.

Interactive Swagger UI is at `http://localhost:3000/api/docs`. The OpenAPI
document is available at `http://localhost:3000/api/openapi.json`.

## REST API

Data routes resolve the fixed fictional JeeAI demo user in development. They
ignore user IDs supplied by clients. Outside development, these routes return
HTTP `503` until authentication is implemented.

| Method and path | Purpose |
| --- | --- |
| `GET /api/contacts?search=Maya&page=1&limit=20` | Search and paginate the current user's contacts. |
| `GET /api/contacts/:id` | Get a contact owned by the current user. |
| `GET /api/conversations?platform=WHATSAPP&search=Maya&page=1&limit=20` | Filter and paginate conversations by latest activity, with contact and latest-message preview. |
| `GET /api/conversations/:id` | Get a conversation owned by the current user. |
| `PATCH /api/conversations/:id/read` | Clear that conversation's unread count. |
| `GET /api/conversations/:id/messages?page=1&limit=50` | Return messages in chronological order. |
| `POST /api/conversations/:id/messages` | Store a local simulated outgoing message. |

Paginated responses contain `data` and `pagination` (`page`, `limit`, `total`,
and `totalPages`). The message endpoint accepts a JSON body such as
`{"content":"Thanks, see you soon!"}`. It stores direction `OUTGOING` and
status `SENT`, and updates the conversation activity timestamp in one database
transaction. It never contacts WhatsApp, Instagram, or Facebook.

In development, for example:

```sh
curl 'http://localhost:3000/api/contacts?search=Maya&page=1&limit=20'
curl 'http://localhost:3000/api/conversations?platform=WHATSAPP'
curl -X POST 'http://localhost:3000/api/conversations/CONVERSATION_UUID/messages' \
  -H 'Content-Type: application/json' \
  -d '{"content":"Thanks, see you soon!"}'
```

## Scripts

| Script | Purpose |
| --- | --- |
| `npm run dev` | Run the TypeScript server with watch/restart. |
| `npm run typecheck` | Type-check source and tests without emitting files. |
| `npm test` | Run HTTP tests and database integration tests when `TEST_DATABASE_URL` is set. |
| `npm run build` | Compile the production server into `dist/`. |
| `npm start` | Start the compiled production server. |
| `npm run check` | Run type-checking, tests, and a production build. |
| `npm run prisma:generate` | Generate the Prisma Client. |
| `npm run db:migrate:init` | Create and apply the initial `init` migration. |
| `npm run db:migrate:dev` | Create/apply a development migration. |
| `npm run db:migrate:deploy` | Apply checked-in migrations in deployment. |
| `npm run db:seed` | Idempotently upsert fictional local sample data. |

## Configuration

Create `.env` from `.env.example` if it does not exist. If `.env` already exists,
keep it and add only missing database variables. Change local placeholder values:

- `NODE_ENV`: `development`, `test`, or `production`.
- `PORT`: HTTP port; defaults to `3000`.
- `DATABASE_URL`: PostgreSQL URL for development/production migrations and seed.
- `TEST_DATABASE_URL`: separate PostgreSQL URL used only when `NODE_ENV=test`.
- `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_PORT`: local
  Docker Compose database settings.
- `CORS_ORIGINS`: comma-separated browser origins. In development, HTTP
  loopback origins (`localhost`, `127.0.0.1`, and `::1`) are also allowed.
  Requests without an `Origin` header, including native app and command-line
  requests, are accepted.

Never commit `.env` or real credentials. The backend `.gitignore` excludes
environment files while keeping `.env.example` tracked.

Prisma reads the datasource URL from `prisma.config.ts`; the schema itself does
not contain credentials. Migrations are checked in under `prisma/migrations/`
and should be applied with Prisma Migrate. Do not use `db push` as the permanent
schema management workflow. The Compose database uses a named volume and keeps
data between restarts; do not remove that volume unless you intend to delete
the local development database.

To run the integration suite against a separate test database, first apply the
same migrations to that empty test database, then run:

```sh
TEST_DATABASE_URL='postgresql://.../jeeai_test?schema=public' npm test
```

Integration tests only delete rows created by their random test user. The seed
test upserts its fixed fictional fixture IDs and checks that rerunning the seed
does not add rows.

## Layout

```text
src/
  app.ts                  Express app and middleware composition
  server.ts               HTTP listener and shutdown handling
  config/                 Environment and OpenAPI configuration
  database/               Prisma singleton, lifecycle, and seed data
  generated/prisma/       Generated Prisma Client (ignored by Git)
  middleware/             CORS, request logging, 404, and error handling
  modules/contacts/       Contact routes, validation, controller, and service
  modules/conversations/  Conversation routes, validation, controller, and service
  modules/messages/       Message routes, validation, controller, and service
  modules/health/         Health route and controller
  routes/                 API route composition
  utils/                  Shared application error type
test/                     API and PostgreSQL integration tests
prisma/                   PostgreSQL schema, migrations, and seed entry point
prisma.config.ts          Prisma 7 datasource, migration, and seed configuration
```
