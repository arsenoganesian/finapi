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

## Quick Start

### Local

```bash
bundle install
bin/rails db:prepare
bin/rails server
```

### Makefile shortcuts

List available commands:

```bash
make help
```

Common usage:

```bash
make setup      # install gems + prepare db
make server     # start rails server
make test       # run rspec suite
make lint       # run rubocop
make security   # run brakeman + bundler-audit
```

### Docker (development)

```bash
docker compose up --build
```

Base URL:

```text
http://localhost:3000
```

Run all tests:

```bash
bin/rails db:create RAILS_ENV=test
bin/rails db:migrate RAILS_ENV=test
bundle exec rspec
```

JWT configuration:

- `JWT_SECRET`: signing secret (defaults to Rails secret key base)
- `JWT_EXPIRATION_SECONDS`: token TTL in seconds (defaults to `3600`)

## API Overview

Public endpoints:

- POST /users
- POST /auth_tokens

Protected endpoints (Bearer token required):

- GET /balance
- PATCH /balance
- POST /transfers

Response format:

- Success: `{ "data": ... }`
- Error: `{ "error": "..." }`

Common status codes:

- 200 OK
- 201 Created
- 401 Unauthorized
- 404 Not Found
- 422 Unprocessable Content

## Endpoints With Curl Examples

### 1) Create user

Request:

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"alice@example.com"}}'
```

Example response (201):

```json
{
  "data": {
    "user_id": "123e4567-e89b-42d3-a456-426614174000",
    "email": "alice@example.com",
    "balance": "0.00"
  }
}
```

Example error (422):

```json
{
  "error": "Email format is invalid"
}
```

### 2) Get auth token

Request:

```bash
curl -X POST http://localhost:3000/auth_tokens \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com"}'
```

Example response (200):

```json
{
  "data": {
    "token": "<jwt-token>"
  }
}
```

Example error (404):

```json
{
  "error": "User not found"
}
```

Store token in shell variable:

```bash
AUTH_TOKEN="<jwt-token>"
```

### 3) Get balance

Request:

```bash
curl -X GET http://localhost:3000/balance \
  -H "Authorization: Bearer $AUTH_TOKEN"
```

Example response (200):

```json
{
  "data": {
    "user_id": "123e4567-e89b-42d3-a456-426614174000",
    "balance": "50.00"
  }
}
```

Example error (401):

```json
{
  "error": "Missing token"
}
```

### 4) Update balance (top-up or withdraw)

Request:

```bash
curl -X PATCH http://localhost:3000/balance \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d '{"amount":"10.00"}'
```

Example response (200):

```json
{
  "data": {
    "user_id": "123e4567-e89b-42d3-a456-426614174000",
    "balance": "60.00"
  }
}
```

Example error (422):

```json
{
  "error": "Amount must not be zero"
}
```

### 5) Transfer to another user

Request:

```bash
curl -X POST http://localhost:3000/transfers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -d '{"transfer":{"recipient_email":"bob@example.com","amount":"25.00"}}'
```

Example response (200):

```json
{
  "data": {
    "user_id": "123e4567-e89b-42d3-a456-426614174000",
    "balance": "75.00"
  }
}
```

Note: transfer response returns only the sender (authenticated user) balance after transfer.

Example errors:

```json
{
  "error": "Insufficient funds for transfer"
}
```

```json
{
  "error": "Recipient not found"
}
```

## Disclaimer

This project is a minimal implementation intended for development and testing.
