#!/usr/bin/env bash
# Development setup script using uv

set -e

echo "🚀 Setting up Promptbook MCP development environment with uv"

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "❌ uv not found. Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "✅ uv installed. Please restart your shell or run: source $HOME/.cargo/env"
    exit 0
fi

echo "📦 Creating virtual environment..."
uv venv

echo "📥 Installing dependencies..."
uv pip sync requirements.lock

echo "🔧 Installing development dependencies..."
uv pip install mypy flake8 pytest pytest-cov pytest-asyncio

echo "✅ Setup complete!"
echo ""
echo "To activate the environment, run:"
echo "  source .venv/bin/activate"
echo ""
echo "Common commands:"
echo "  uv run pytest              # Run tests"
echo "  uv run mypy --strict .     # Type checking"
echo "  uv run flake8 .            # Linting"
echo "  uv run python mcp_server.py  # Start server"
