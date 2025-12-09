#!/bin/bash
# setup.sh - One-command setup for MCP Prompt Library
# Supports both uv (recommended) and traditional pip workflows

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC}  $1"
}

# Banner
echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║   🤖 MCP Prompt Library Setup                ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""

# Check if uv is available
USE_UV=false
if command -v uv &> /dev/null; then
    print_success "uv detected - using fast dependency management"
    USE_UV=true
else
    print_warning "uv not found - using traditional pip (slower)"
    echo "           Install uv for 10-100x faster installs:"
    echo "           ${BLUE}curl -LsSf https://astral.sh/uv/install.sh | sh${NC}"
    echo ""
fi

# Check Python version
print_step "Checking Python version..."
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 not found. Please install Python 3.10 or higher."
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || { [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 10 ]; }; then
    print_error "Python 3.10+ required. Found: $PYTHON_VERSION"
    exit 1
fi

print_success "Python $PYTHON_VERSION detected"

# Setup environment based on tool
if [ "$USE_UV" = true ]; then
    # UV workflow
    print_step "Setting up with uv..."
    
    if [ -d ".venv" ]; then
        print_warning "Virtual environment exists. Removing for fresh setup..."
        rm -rf .venv
    fi
    
    uv venv
    print_success "Virtual environment created"
    
    # Activate virtual environment
    print_step "Activating virtual environment..."
    if [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
        print_success "Virtual environment activated"
    else
        print_error "Failed to activate virtual environment"
        exit 1
    fi
    
    print_step "Installing dependencies..."
    uv pip sync requirements.lock
    print_success "Production dependencies installed"
    
    print_step "Installing dev dependencies..."
    uv pip install mypy flake8 pytest pytest-cov pytest-asyncio
    print_success "Development tools installed"
    
else
    # Traditional pip workflow
    print_step "Creating virtual environment..."
    if [ -d ".venv" ]; then
        print_warning "Virtual environment already exists. Skipping creation."
    else
        python3 -m venv .venv
        print_success "Virtual environment created"
    fi
    
    # Activate virtual environment
    print_step "Activating virtual environment..."
    if [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
        print_success "Virtual environment activated"
    else
        print_error "Failed to activate virtual environment"
        exit 1
    fi
    
    # Upgrade pip
    print_step "Upgrading pip..."
    python -m pip install --upgrade pip --quiet
    print_success "pip upgraded"
    
    # Install dependencies
    print_step "Installing dependencies..."
    pip install -r requirements.lock --quiet
    
    # Check if installation succeeded
    if [ $? -eq 0 ]; then
        print_success "Dependencies installed"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
fi

# Create necessary directories
print_step "Creating directories..."
mkdir -p prompts sessions
mkdir -p prompts/{refactoring,testing,debugging,implementation,documentation,general,code-review}
print_success "Directories created"

# Create .env file if not exists
if [ ! -f ".env" ]; then
    print_step "Creating .env file from template..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_success ".env file created"
        print_warning "Please review and update .env file with your settings"
    else
        print_warning ".env.example not found. Skipping .env creation."
    fi
else
    print_warning ".env already exists. Not overwriting."
fi

# Final instructions
echo ""
echo "╔═══════════════════════════════════════════════╗"
echo "║   ✅ Setup Complete!                          ║"
echo "╚═══════════════════════════════════════════════╝"
echo ""
echo "📚 Next steps:"
echo ""
echo "  1. Activate the environment:"
if [ "$USE_UV" = true ]; then
    echo -e "     ${GREEN}source .venv/bin/activate${NC}  (already activated)"
else
    echo -e "     ${GREEN}source .venv/bin/activate${NC}  (already activated)"
fi
echo ""
echo "  2. Start the MCP server:"
if [ "$USE_UV" = true ]; then
    echo -e "     ${GREEN}uv run python mcp_server.py${NC}"
else
    echo -e "     ${GREEN}python mcp_server.py${NC}"
fi
echo ""
echo "  3. Run quality checks:"
if [ "$USE_UV" = true ]; then
    echo -e "     ${GREEN}make quality${NC}   (or: uv run pytest, uv run mypy --strict .)"
else
    echo -e "     ${GREEN}pytest && mypy --strict .${NC}"
fi
echo ""
echo "  4. Or use Docker:"
echo -e "     ${GREEN}docker-compose up -d${NC}"
echo ""
echo "📖 Documentation: ./README.md"
if [ "$USE_UV" = false ]; then
    echo ""
    echo "💡 Tip: Install uv for 10-100x faster dependency management:"
    echo -e "   ${BLUE}curl -LsSf https://astral.sh/uv/install.sh | sh${NC}"
fi
echo ""
echo "Happy prompting! 🚀"
echo ""
