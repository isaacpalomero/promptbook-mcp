# Contributing to MCP Prompt Library

First off, thank you for considering contributing to MCP Prompt Library! 🎉

It's people like you that make this project better for everyone.

## 🤔 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When you create a bug report, include as many details as possible:

**Bug Report Template:**

```markdown
**Description:**
Brief description of the bug

**Steps to Reproduce:**
1. Go to '...'
2. Run command '....'
3. See error

**Expected behavior:**
What you expected to happen

**Actual behavior:**
What actually happened

**Environment:**
- OS: [e.g., macOS 14.1]
- Python version: [e.g., 3.11.5]
- Docker version (if applicable): [e.g., 24.0.6]

**Additional context:**
Any other context about the problem
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- Use a clear and descriptive title
- Provide a detailed description of the proposed enhancement
- Explain why this enhancement would be useful
- List examples of how it would be used

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Add tests** for new features
4. **Ensure tests pass**: `pytest`
5. **Update documentation** if needed
6. **Commit with clear messages** following [Conventional Commits](https://www.conventionalcommits.org/)
7. **Push to your fork** and submit a Pull Request

## 🏗️ Development Setup

### Prerequisites

- Python 3.11+
- Git
- (Optional) Docker for container testing

### Setup Steps

```bash
# 1. Fork and clone
git clone https://github.com/isaacpalomero/mcp_tools.git
cd mcp_tools

# 2. Run automated setup
chmod +x setup.sh
./setup.sh

# 3. Activate virtual environment
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# 4. Install development dependencies
pip install pytest pytest-cov flake8 mypy black

# 5. Run tests to verify setup
pytest
```

## 📝 Coding Standards

### Python Style Guide

We follow [PEP 8](https://pep8.org/) with these specifics:

- **Line length:** Maximum 100 characters
- **Indentation:** 4 spaces (no tabs)
- **Quotes:** Single quotes for strings (unless double needed)
- **Imports:** Organize imports (stdlib, third-party, local)

### Code Formatting

We use **Black** for automatic formatting:

```bash
# Format code
black .

# Check formatting
black --check .
```

### Type Hints

All public functions and methods must have type hints:

```python
# ✅ Good
def search_prompts(query: str, n_results: int = 5) -> List[Dict]:
    pass

# ❌ Bad
def search_prompts(query, n_results=5):
    pass
```

### Docstrings

Use Google-style docstrings for all public functions:

```python
def calculate_similarity(text1: str, text2: str) -> float:
    """
    Calculate semantic similarity between two texts.
    
    Args:
        text1: First text to compare
        text2: Second text to compare
        
    Returns:
        Similarity score between 0.0 and 1.0
        
    Raises:
        ValueError: If either text is empty
        
    Examples:
        >>> calculate_similarity("hello world", "hello there")
        0.85
    """
    pass
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=. --cov-report=html

# Run specific test file
pytest tests/unit/test_mcp_server.py

# Run with verbose output
pytest -v

# Run only unit tests
pytest tests/unit/

# Run only integration tests
pytest tests/integration/
```

### Writing Tests

- Place tests in `tests/` directory
- Name test files `test_*.py`
- Name test functions `test_*`
- Use descriptive test names: `test_search_prompts_returns_relevant_results`

**Example test:**

```python
def test_create_prompt_with_valid_content():
    """Test that create_prompt successfully creates a prompt"""
    content = "Test prompt content"
    result = create_prompt(content=content, category="testing")
    
    assert "✅ Prompt created successfully!" in result[0].text
    assert "testing" in result[0].text
```

## 📋 Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Format
<type>(<scope>): <description>

# Types
feat:     New feature
fix:      Bug fix
docs:     Documentation changes
style:    Code style changes (formatting, etc.)
refactor: Code refactoring
test:     Adding or updating tests
chore:    Maintenance tasks

# Examples
feat(rag): add multi-language embedding support
fix(mcp): resolve path traversal vulnerability
docs(readme): update installation instructions
test(organizer): add tests for session parsing
```

## 🔍 Code Review Process

All submissions require review. We use GitHub Pull Requests:

1. **Automated checks** must pass (tests, linting)
2. **At least one approval** from maintainer required
3. **No merge conflicts** with main branch
4. **Documentation updated** if adding features
5. **Tests included** for new functionality

### Review Checklist

Reviewers will check:

- [ ] Code follows style guidelines
- [ ] Tests pass and cover new code
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] No unnecessary changes included
- [ ] Performance impact considered

## 🎯 Priority Areas

Areas where we especially welcome contributions:

- 🧪 **Test coverage** - Improving test suite
- 📖 **Documentation** - Examples, guides, tutorials
- 🐛 **Bug fixes** - Check [Issues](../../issues)
- ✨ **Features** - See project roadmap
- 🌍 **Internationalization** - Multi-language support
- 🚀 **Performance** - Optimization improvements

## 📞 Getting Help

- 💬 [GitHub Discussions](../../discussions)
- 🐛 [Issue Tracker](../../issues)
- 📖 [Documentation](./docs/)

## 📜 Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code.

**In short:**
- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism gracefully
- Focus on what's best for the community

## 🙏 Recognition

Contributors are recognized in:
- [Contributors page](../../graphs/contributors)
- Release notes for their contributions
- Community shoutouts

Thank you for contributing! 🎉
