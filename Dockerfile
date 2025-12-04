# syntax=docker/dockerfile:1
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

# Copy dependency files
COPY pyproject.toml requirements.lock ./

# Install dependencies with uv
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install --system --no-cache -r requirements.lock

# Copy application code
COPY . /app

FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PROMPTS_DIR=/app/prompts \
    SESSIONS_DIR=/app/sessions \
    VECTOR_DB_DIR=/app/prompts/.vectordb

WORKDIR /app

# Create non-root user
RUN addgroup --system app && adduser --system --ingroup app app

# Copy Python environment and application from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/python* /usr/local/bin/
COPY --from=builder /app /app

# Create required directories
RUN mkdir -p "$PROMPTS_DIR" "$SESSIONS_DIR" \
    && chown -R app:app /app

USER app

# Healthcheck: verify server process and dependencies
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import sys; \
from pathlib import Path; \
from prompt_rag import PromptRAG; \
from mcp.server import Server; \
prompts_dir = Path('/app/prompts'); \
assert prompts_dir.exists(), 'prompts_dir missing'; \
print('healthy'); \
sys.exit(0)" || exit 1

CMD ["python", "mcp_server.py"]
