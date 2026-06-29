.PHONY: help setup server console routes db-create db-migrate db-prepare db-reset test lint security

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "%-14s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Install gems and prepare the local database
	bundle install
	bin/rails db:prepare

server: ## Start Rails server locally
	bin/rails server

console: ## Open Rails console
	bin/rails console

routes: ## Show Rails routes
	bin/rails routes

db-create: ## Create development database
	bin/rails db:create

db-migrate: ## Run database migrations
	bin/rails db:migrate

db-prepare: ## Prepare database (create + migrate + seed when needed)
	bin/rails db:prepare

db-reset: ## Drop, create, migrate and seed database
	bin/rails db:reset

test: ## Run test suite
	bundle exec rspec

lint: ## Run RuboCop
	bin/rubocop

security: ## Run security checks (Brakeman + bundler-audit)
	bin/brakeman
	bin/bundler-audit
