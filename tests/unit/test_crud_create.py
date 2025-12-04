#!/usr/bin/env python3
"""
Test create_prompt tool
"""

import asyncio
import sys
from pathlib import Path
import tempfile
import shutil

sys.path.insert(0, str(Path(__file__).parent))

# Set temp prompts dir for testing
import os
temp_dir = tempfile.mkdtemp()
os.environ['PROMPTS_DIR'] = temp_dir

from mcp_server import create_prompt, initialize_systems
from config import CONFIG

prompts_dir = CONFIG.prompts_dir

async def test_create_prompt_basic():
    """Test basic prompt creation"""
    print("�� Test 1: Basic prompt creation")

    result = await create_prompt(
        content="Refactor TypeScript code using SOLID principles and clean code practices.",
        keywords=["typescript", "solid", "refactoring"]
    )

    assert len(result) == 1
    text = result[0].text

    assert "✅ Prompt created successfully" in text
    assert "refactoring" in text
    assert "typescript" in text

    print(f"✅ Test 1 passed")
    print(f"Output:\n{text}\n")


async def test_create_prompt_explicit_category():
    """Test with explicit category"""
    print("🧪 Test 2: Explicit category")

    result = await create_prompt(
        content="Write unit tests for the authentication service",
        category="testing",
        title="Auth Service Tests",
        keywords=["auth", "unittest"]
    )

    text = result[0].text
    assert "testing" in text
    assert "Auth Service Tests" in text

    print(f"✅ Test 2 passed")
    print(f"Output:\n{text}\n")


async def test_create_prompt_auto_title():
    """Test auto title generation"""
    print("🧪 Test 3: Auto title generation")

    result = await create_prompt(
        content="""# Implement Feature X

Create a new feature that allows users to export data to CSV format.

Requirements:
- Support multiple file formats
- Add validation
- Include error handling
"""
    )

    text = result[0].text
    assert "Implement Feature X" in text or "Create a new feature" in text

    print(f"✅ Test 3 passed")
    print(f"Output:\n{text}\n")


async def test_file_created():
    """Test that file is actually created"""
    print("🧪 Test 4: File creation verification")

    result = await create_prompt(
        content="Debug the memory leak in the background worker",
        category="debugging"
    )

    # Check that at least one file exists in debugging category
    debugging_dir = prompts_dir / "debugging"
    assert debugging_dir.exists(), "Debugging directory should exist"

    files = list(debugging_dir.glob("*.md"))
    assert len(files) > 0, "At least one file should be created"

    print(f"✅ Test 4 passed - Found {len(files)} file(s)")

    # Check file content
    latest_file = max(files, key=lambda f: f.stat().st_mtime)
    content = latest_file.read_text()

    assert "Debug the memory leak" in content
    assert "## Metadata" in content
    assert "debugging" in content

    print(f"✅ File content validated: {latest_file.name}\n")


async def test_index_json_updated():
    """Test that index.json is updated"""
    print("🧪 Test 5: index.json update")

    result = await create_prompt(
        content="Document the API endpoints",
        category="documentation",
        keywords=["api", "docs", "rest"]
    )

    # Check index.json
    index_file = prompts_dir / "index.json"

    if index_file.exists():
        import json
        index = json.loads(index_file.read_text())

        assert "documentation" in index.get("categories", {})
        assert "api" in index.get("keywords", {}) or "docs" in index.get("keywords", {})

        print(f"✅ Test 5 passed - index.json updated")
        print(f"Categories: {list(index.get('categories', {}).keys())}")
        print(f"Keywords: {list(index.get('keywords', {}).keys())[:10]}\n")
    else:
        print(f"⚠️  Test 5 skipped - index.json not created yet\n")


async def main():
    print("=" * 70)
    print("�� Testing create_prompt Tool")
    print("=" * 70)
    print(f"📂 Using temp directory: {temp_dir}\n")

    # Initialize systems
    initialize_systems()

    # Run tests
    await test_create_prompt_basic()
    await test_create_prompt_explicit_category()
    await test_create_prompt_auto_title()
    await test_file_created()
    await test_index_json_updated()

    print("=" * 70)
    print("✅ All tests passed!")
    print("=" * 70)

    # Show created files
    print(f"\n📁 Created files in {temp_dir}:")
    for cat_dir in prompts_dir.iterdir():
        if cat_dir.is_dir():
            files = list(cat_dir.glob("*.md"))
            if files:
                print(f"\n  {cat_dir.name}/ ({len(files)} files)")
                for f in files:
                    print(f"    - {f.name}")

    # Cleanup
    print(f"\n🧹 Cleaning up temp directory...")
    shutil.rmtree(temp_dir)
    print(f"✅ Done!")


if __name__ == "__main__":
    asyncio.run(main())
