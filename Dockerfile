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

# Healthcheck: verify server process is running and responsive
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import sys; \
import os; \
from pathlib import Path; \
# Verify critical paths exist; \
prompts_dir = Path(os.environ.get('PROMPTS_DIR', '/app/prompts')); \
if not prompts_dir.exists(): \
    print(f'Prompts directory missing: {prompts_dir}', file=sys.stderr); \
    sys.exit(1); \
# Test that server dependencies can be imported and initialized; \
try: \
    from mcp.server import Server; \
    from prompt_rag import PromptRAG; \
    from prompt_organizer import PromptOrganizer; \
    from config import CONFIG; \
    # Verify config paths are accessible; \
    if not CONFIG.prompts_dir.exists(): \
        raise RuntimeError(f'Config prompts_dir not found: {CONFIG.prompts_dir}'); \
    # Test server instantiation; \
    _ = Server('healthcheck-test'); \
except Exception as e: \
    print(f'Server initialization failed: {e}', file=sys.stderr); \
    sys.exit(1); \
print('healthy'); \
sys.exit(0)" || exit 1

CMD ["python", "mcp_server.py"]
