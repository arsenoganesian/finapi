# FinAPI

Simple Rails API for user balances and internal transfers.

## Stack

- Ruby on Rails (API mode)
- PostgreSQL
- RSpec + factory_bot

## Architecture

- Controllers: request/response only
- Services: business logic
- Infrastructure: external/technical concerns (e.g., JWT codec)
- Models: persistence
- Serializers: JSON rendering

## Setup

### Local

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

### Make Commands

Use `make help` to see available commands.

```bash
make help
```

### Docker

```bash
docker compose up --build
```

### Test Suite

```bash
bin/rails db:create RAILS_ENV=test
bin/rails db:migrate RAILS_ENV=test
bundle exec rspec
```

## Configuration

### Base URL

```text
http://localhost:3000
```

### JWT

- `JWT_SECRET`: signing secret (defaults to Rails secret key base)
- `JWT_EXPIRATION_SECONDS`: token TTL in seconds (defaults to `3600`)

## API

### Endpoints

Public endpoints:

- POST /users
- POST /auth_tokens

Protected endpoints (Bearer token required):

- GET /balance
- PATCH /balance
- POST /transfers

### Response Format

- Success: `{ "data": ... }`
- Error: `{ "error": "..." }`

### Status Codes

- 200 OK
- 201 Created
- 401 Unauthorized
- 404 Not Found
- 422 Unprocessable Content

## Examples

### Create User

Request:

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"alice@example.com"}}'
```

Response `201 Created`:

```json
{
  "data": {
    "user_id": "123e4567-e89b-42d3-a456-426614174000",
    "email": "alice@example.com",
    "balance": "0.00"
  }
}
```

Error `422 Unprocessable Content`:

```json
{
  "error": "Email format is invalid"
}
```

### Create Auth Token

Request:

```bash
curl -X POST http://localhost:3000/auth_tokens \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com"}'
```

Response `200 OK`:

```json
{
  "data": {
    "token": "<jwt-token>"
  }
}
```

Error `404 Not Found`:

```json
{
  "error": "User not found"
}
```

Store the token for later requests:

```bash
export AUTH_TOKEN="<jwt-token>"
```

### Get Balance

Request:

```bash
curl -X GET http://localhost:3000/balance \
  -H "Authorization: Bearer $AUTH_TOKEN"
```

Response `200 OK`:

```json
{
  "data": {
    "user_id": "123e4567-e89b-42d3-a456-426614174000",
    "balance": "50.00"
  }
}
```

Error `401 Unauthorized`:

```json
{
  "error": "Missing token"
}
```

### Update Balance

Request:

```bash
curl -X PATCH http://localhost:3000/balance \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d '{"amount":"10.00"}'
```

Response `200 OK`:

```json
{
  "data": {
    "user_id": "123e4567-e89b-42d3-a456-426614174000",
    "balance": "60.00"
  }
}
```

Error `422 Unprocessable Content`:

```json
{
  "error": "Amount must not be zero"
}
```

### Create Transfer

Request:

```bash
curl -X POST http://localhost:3000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d '{"transfer":{"recipient_email":"bob@example.com","amount":"25.00"}}'
```

Response `200 OK`:

```json
{
  "data": {
    "user_id": "123e4567-e89b-42d3-a456-426614174000",
    "balance": "75.00"
  }
}
```

The transfer response returns only the authenticated sender balance after the transfer.

Error `422 Unprocessable Content`:

```json
{
  "error": "Insufficient funds for transfer"
}
```

Error `404 Not Found`:

```json
{
  "error": "Recipient not found"
}
```

## Disclaimer

This project is a minimal implementation intended for development and testing.
