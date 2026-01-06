.PHONY: help up down build restart logs shell composer-install migrate generate-keys test

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

up: ## Start all services
	docker-compose up -d

down: ## Stop all services
	docker-compose down

build: ## Build Docker images
	docker-compose build --no-cache

restart: down up ## Restart all services

logs: ## Show logs from all services
	docker-compose logs -f

logs-php: ## Show PHP logs
	docker-compose logs -f php

logs-nginx: ## Show Nginx logs
	docker-compose logs -f nginx

shell: ## Access PHP container shell
	docker-compose exec php sh

shell-postgres: ## Access PostgreSQL shell
	docker-compose exec postgres psql -U auth_user -d auth_db

composer-install: ## Install PHP dependencies
	docker-compose exec php composer install

composer-update: ## Update PHP dependencies
	docker-compose exec php composer update

migrate: ## Run database migrations
	docker-compose exec php bin/console doctrine:migrations:migrate --no-interaction

migrate-create: ## Create a new migration
	docker-compose exec php bin/console doctrine:migrations:generate

generate-keys: ## Generate JWT RSA keys
	docker-compose exec php bin/console app:generate-jwt-keys

process-outbox: ## Process outbox events manually
	docker-compose exec php bin/console app:process-outbox-events

test: ## Run tests
	docker-compose exec php vendor/bin/phpunit

test-unit: ## Run unit tests only
	docker-compose exec php vendor/bin/phpunit --testsuite=unit

test-integration: ## Run integration tests only
	docker-compose exec php vendor/bin/phpunit --testsuite=integration

coverage: ## Generate code coverage report
	docker-compose exec php vendor/bin/phpunit --coverage-html var/coverage

cs-fix: ## Fix code style
	docker-compose exec php vendor/bin/php-cs-fixer fix src

phpstan: ## Run static analysis
	docker-compose exec php vendor/bin/phpstan analyse src

cache-clear: ## Clear application cache
	docker-compose exec php bin/console cache:clear

db-reset: ## Reset database (drop, create, migrate)
	docker-compose exec php bin/console doctrine:database:drop --force --if-exists
	docker-compose exec php bin/console doctrine:database:create
	docker-compose exec php bin/console doctrine:migrations:migrate --no-interaction

init: build up composer-install generate-keys migrate ## Initialize project (first time setup)
	@echo "✓ Project initialized successfully!"
	@echo "  Access the API at: http://localhost:8080"
	@echo "  RabbitMQ Management: http://localhost:15672 (guest/guest)"