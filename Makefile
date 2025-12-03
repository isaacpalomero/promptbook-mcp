# Promptbook MCP - Development Commands with uv

.PHONY: help install test lint typecheck format clean run docker-build docker-run

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install all dependencies with uv
	uv pip sync requirements.lock
	uv pip install mypy flake8 pytest pytest-cov pytest-asyncio

install-dev: ## Create venv and install dependencies
	uv venv
	uv pip sync requirements.lock
	uv pip install mypy flake8 pytest pytest-cov pytest-asyncio

test: ## Run tests with coverage
	uv run pytest --cov=. --cov-report=term --cov-report=html

test-verbose: ## Run tests with verbose output
	uv run pytest -vv --cov=. --cov-report=term

lint: ## Run flake8 linter
	uv run flake8 .

typecheck: ## Run mypy type checker
	uv run mypy --strict .

format-check: ## Check code formatting (placeholder for future ruff/black)
	@echo "Format checking not yet configured"

quality: lint typecheck test ## Run all quality checks

clean: ## Clean build artifacts and caches
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf htmlcov coverage.xml .coverage

run: ## Run the MCP server
	uv run python mcp_server.py

run-watcher: ## Run the file watcher
	uv run python watcher.py

run-watcher-rag: ## Run the RAG-enabled watcher
	uv run python watcher_rag.py

docker-build: ## Build Docker image
	docker build -t promptbook-mcp:latest .

docker-run: ## Run Docker container
	docker run -it --rm \
		-v $(PWD)/prompts:/app/prompts \
		-v $(PWD)/sessions:/app/sessions \
		-e LOG_LEVEL=INFO \
		promptbook-mcp:latest

docker-compose-up: ## Start services with docker-compose
	docker-compose up -d

docker-compose-down: ## Stop services
	docker-compose down

update-deps: ## Update dependencies (regenerate lockfile)
	uv pip compile pyproject.toml -o requirements.lock
