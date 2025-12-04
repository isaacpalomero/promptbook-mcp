#!/usr/bin/env python3
"""
Test update_prompt and delete_prompt tools
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

from mcp_server import create_prompt, update_prompt, delete_prompt, initialize_systems
from config import CONFIG

prompts_dir = CONFIG.prompts_dir

async def test_update_prompt_content():
    """Test updating prompt content"""
    print("=" * 70)
    print("🧪 Test 1: Update prompt content")
    print("=" * 70)

    # Create a prompt first
    result = await create_prompt(
        content="Original content about testing",
        category="testing",
        title="Original Title",
        keywords=["test", "original"]
    )

    # Extract file path from result
    file_path = result[0].text.split("File:** ")[1].split("\n")[0]
    print(f"Created: {file_path}")

    # Update the content
    result = await update_prompt(
        file_path=file_path,
        content="Updated content about advanced testing strategies"
    )

    assert "✅ Prompt updated successfully" in result[0].text
    assert "content" in result[0].text

    print("✅ Test 1 passed")
    print(result[0].text)
    print()


async def test_update_prompt_category():
    """Test changing category (moves file)"""
    print("=" * 70)
    print("🧪 Test 2: Update prompt category (move file)")
    print("=" * 70)

    # Create a prompt
    result = await create_prompt(
        content="Debugging content",
        category="debugging",
        keywords=["debug"]
    )

    file_path = result[0].text.split("File:** ")[1].split("\n")[0]
    print(f"Created in debugging: {file_path}")

    # Change category to refactoring
    result = await update_prompt(
        file_path=file_path,
        category="refactoring"
    )

    assert "✅ Prompt updated successfully" in result[0].text
    assert "refactoring" in result[0].text
    assert "debugging → refactoring" in result[0].text

    # Verify file moved
    new_path = result[0].text.split("File:** ")[1].split("\n")[0]
    assert "refactoring" in new_path

    print("✅ Test 2 passed")
    print(result[0].text)
    print()


async def test_update_prompt_multiple_fields():
    """Test updating multiple fields at once"""
    print("=" * 70)
    print("🧪 Test 3: Update multiple fields")
    print("=" * 70)

    # Create a prompt
    result = await create_prompt(
        content="Basic implementation",
        category="implementation",
        title="Basic Feature",
        keywords=["basic"]
    )

    file_path = result[0].text.split("File:** ")[1].split("\n")[0]

    # Update multiple fields
    result = await update_prompt(
        file_path=file_path,
        content="Advanced implementation with new features",
        title="Advanced Feature Implementation",
        keywords=["advanced", "feature", "implementation"]
    )

    text = result[0].text
    assert "✅ Prompt updated successfully" in text
    assert "Advanced Feature Implementation" in text
    assert "advanced, feature, implementation" in text
    assert "content" in text
    assert "title" in text
    assert "keywords" in text

    print("✅ Test 3 passed")
    print(result[0].text)
    print()


async def test_delete_prompt_without_confirm():
    """Test delete requires confirmation"""
    print("=" * 70)
    print("🧪 Test 4: Delete without confirmation")
    print("=" * 70)

    # Create a prompt
    result = await create_prompt(
        content="Content to delete",
        category="general",
        title="To Be Deleted"
    )

    file_path = result[0].text.split("File:** ")[1].split("\n")[0]

    # Try to delete without confirmation
    result = await delete_prompt(file_path=file_path, confirm=False)

    text = result[0].text
    assert "⚠️  Confirmation required" in text
    assert "This action cannot be undone" in text
    assert "confirm: true" in text

    # Verify file still exists
    full_path = prompts_dir / file_path
    assert full_path.exists(), "File should still exist"

    print("✅ Test 4 passed")
    print(result[0].text)
    print()


async def test_delete_prompt_with_confirm():
    """Test actual deletion with confirmation"""
    print("=" * 70)
    print("🧪 Test 5: Delete with confirmation")
    print("=" * 70)

    # Create a prompt
    result = await create_prompt(
        content="Content to delete",
        category="general",
        title="To Be Deleted"
    )

    file_path = result[0].text.split("File:** ")[1].split("\n")[0]
    full_path = prompts_dir / file_path

    # Verify file exists
    assert full_path.exists(), "File should exist before deletion"

    # Delete with confirmation
    result = await delete_prompt(file_path=file_path, confirm=True)

    text = result[0].text
    assert "✅ Prompt deleted successfully" in text
    assert "File system ✅" in text
    assert "RAG index ✅" in text

    # Verify file deleted
    assert not full_path.exists(), "File should be deleted"

    print("✅ Test 5 passed")
    print(result[0].text)
    print()


async def test_update_nonexistent_prompt():
    """Test updating non-existent prompt"""
    print("=" * 70)
    print("🧪 Test 6: Update non-existent prompt (error handling)")
    print("=" * 70)

    result = await update_prompt(
        file_path="nonexistent/fake_prompt.md",
        content="new content"
    )

    assert "❌ Prompt not found" in result[0].text

    print("✅ Test 6 passed")
    print(result[0].text)
    print()


async def test_delete_nonexistent_prompt():
    """Test deleting non-existent prompt"""
    print("=" * 70)
    print("🧪 Test 7: Delete non-existent prompt (error handling)")
    print("=" * 70)

    result = await delete_prompt(
        file_path="nonexistent/fake_prompt.md",
        confirm=True
    )

    assert "❌ Prompt not found" in result[0].text

    print("✅ Test 7 passed")
    print(result[0].text)
    print()


async def main():
    print("=" * 70)
    print("🔬 Testing update_prompt and delete_prompt Tools")
    print("=" * 70)
    print(f"📂 Using temp directory: {temp_dir}\n")

    # Initialize systems
    initialize_systems()

    # Run tests
    await test_update_prompt_content()
    await test_update_prompt_category()
    await test_update_prompt_multiple_fields()
    await test_delete_prompt_without_confirm()
    await test_delete_prompt_with_confirm()
    await test_update_nonexistent_prompt()
    await test_delete_nonexistent_prompt()

    print("=" * 70)
    print("✅ All tests passed!")
    print("=" * 70)

    # Show remaining files
    print(f"\n📁 Remaining files in {temp_dir}:")
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
