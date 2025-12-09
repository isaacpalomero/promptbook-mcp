# 🚀 Prompt Library Setup Guide

Complete guide to set up the Prompt Library with MCP Server.

## 📋 Prerequisites

- Python 3.11+
- Docker (optional, for containerized deployment)
- Claude Desktop or any MCP-compatible client

## 🎯 Quick Start (3 minutes)

### Option 1: Local Python Setup

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Test the setup
./test_mcp_setup.sh

# 3. Start the watcher (auto-organizes sessions)
python3 watcher_rag.py

# 4. In another terminal, start MCP server
python3 mcp_server.py
```

### Option 2: Docker Setup (Recommended)

```bash
# 1. Build and start services
docker compose -f docker-compose-full.yml up -d

# 2. Check logs
docker compose -f docker-compose-full.yml logs -f

# 3. Test MCP server
docker exec prompt-library-mcp-server python mcp_server.py --help
```

## 🔌 Configure Claude Desktop

1. **Locate Claude config:**
   ```bash
   # macOS
   ~/Library/Application Support/Claude/claude_desktop_config.json
   
   # Windows
   %APPDATA%\Claude\claude_desktop_config.json
   ```

2. **Add MCP server:**
   ```json
   {
     "mcpServers": {
       "prompt-library": {
         "command": "python3",
         "args": [
           "/FULL/PATH/TO/mcp_tools/mcp_server.py"
         ]
       }
     }
   }
   ```

3. **Restart Claude Desktop**

4. **Verify:** Open Claude and check for new tools (search icon)

## 📁 Directory Structure

```
mcp_tools/
├── sessions/              # Place exported Copilot sessions here
├── prompts/              # Auto-organized prompts
│   ├── refactoring/
│   ├── testing/
│   ├── debugging/
│   ├── implementation/
│   ├── documentation/
│   ├── general/
│   ├── .vectordb/       # RAG vector database
│   └── index.json       # Metadata index
├── mcp_server.py        # MCP Server
├── watcher_rag.py       # Auto-organizer with RAG
├── prompt_rag.py        # RAG system
└── prompt_organizer.py  # Session parser
```

## 🔄 Workflow

### 1. Export Session from Copilot CLI
After a productive session with Copilot CLI, export it:
- Look for export option in Copilot CLI
- Save as markdown file

### 2. Move to sessions/
```bash
cp ~/Downloads/copilot-session-*.md ./sessions/
```

### 3. Automatic Processing
The watcher will:
1. ✅ Detect new file
2. 📊 Parse and extract prompts
3. 🗂️ Organize by category
4. 🧠 Index in RAG system
5. 💾 Update metadata

### 4. Search via MCP
In Claude Desktop or any MCP client:
```
"Find me prompts about refactoring TypeScript code"
```

Claude will use the `search_prompts` tool automatically.

## 🧪 Testing

### Test MCP Server Locally

```bash
# Start server
python3 mcp_server.py

# It will output startup logs
# Server runs on stdio (no HTTP endpoint)
```

### Test RAG System

```bash
# Index prompts
python3 prompt_rag.py --index

# Search
python3 prompt_rag.py --search "refactoring clean code"

# Stats
python3 prompt_rag.py --stats
```

### Test Session Processing

```bash
# Process a session manually
python3 prompt_organizer.py --organize copilot-session-*.md
```

### Quality Gate (CI Parity)

```bash
flake8 .
mypy --strict
pytest --cov=. --cov-report=xml
```

The GitHub Actions workflow mirrors these steps on Python 3.11–3.12 and uploads `coverage.xml` for visibility.

## 🐳 Docker Commands

```bash
# Start all services
docker compose -f docker-compose-full.yml up -d

# View logs
docker compose -f docker-compose-full.yml logs -f prompt-organizer
docker compose -f docker-compose-full.yml logs -f mcp-server

# Stop services
docker compose -f docker-compose-full.yml down

# Rebuild after code changes
docker compose -f docker-compose-full.yml build --no-cache
docker compose -f docker-compose-full.yml up -d

# Execute command in container
docker exec prompt-library-mcp-server python prompt_rag.py --stats
```

## 🎯 MCP Tools Usage

### In Claude Desktop

**1. Search for prompts:**
> "I need a prompt for testing automation in TypeScript"

Claude will call `search_prompts` with appropriate query.

**2. Get specific prompt:**
> "Show me the full content of that first prompt"

Claude will call `get_prompt_by_file`.

**3. Find related:**
> "Find similar prompts to this one"

Claude will call `find_similar_prompts`.

### In Cline (VS Code)

Same workflow - Cline will detect and use MCP tools automatically.

## 🔧 Troubleshooting

### MCP Server not appearing in Claude

1. Check config path is correct
2. Verify Python path: `which python3`
3. Test server manually: `python3 mcp_server.py`
4. Check Claude logs (Help → Show Logs)

### RAG system errors

```bash
# Reinitialize RAG
python3 prompt_rag.py --reindex

# Check vector database
ls -la prompts/.vectordb/
```

### Watcher not detecting files

```bash
# Check permissions
ls -la sessions/

# Restart watcher
docker compose restart prompt-organizer

# Check logs
docker compose logs -f prompt-organizer
```

### Port already in use (Docker)

```bash
# Change port in docker-compose-full.yml
ports:
  - "3001:3000"  # Use 3001 instead
```

## 📊 Monitoring

### Check system status

```bash
# Via MCP tool
echo "Get library stats" | use get_library_stats tool

# Via command line
python3 prompt_rag.py --stats

# Docker
docker compose ps
```

### View processed sessions

```bash
# List all prompts
find prompts -name "*.md" -not -name "README.md"

# By category
ls -la prompts/refactoring/

# Index info
cat prompts/index.json | python3 -m json.tool
```

## 🎓 Advanced Usage

### Custom Categories

Edit `prompt_organizer.py` → `_classify_prompt()`:

```python
if any(word in text_lower for word in ['your', 'keywords']):
    return 'your-category'
```

Then add category folder:
```bash
mkdir prompts/your-category
```

### Custom Chunking

Edit `prompt_rag.py` → `chunk_prompt()`:

```python
chunk_size = 1000  # Larger chunks
overlap = 200      # More overlap
```

### Different Embedding Model

Edit `prompt_rag.py`:

```python
model_name="all-mpnet-base-v2"  # Better quality, slower
```

## 📚 Resources

- [MCP Documentation](https://modelcontextprotocol.io/)
- [ChromaDB Docs](https://docs.trychroma.com/)
- [Sentence Transformers](https://www.sbert.net/)

## 💡 Tips

1. **Regular exports:** Export sessions after important work
2. **Descriptive prompts:** Use structured prompts (ROL/CONTEXTO/OBJETIVO)
3. **Tag sessions:** Add keywords to help RAG indexing
4. **Backup:** Keep `prompts/index.json` backed up
5. **Rebuild RAG:** Reindex after bulk changes

## ⚡ Performance

- Initial RAG indexing: ~2-3 minutes for 100 prompts
- Search query: <1 second
- Session processing: ~5 seconds
- Memory usage: ~500MB (model + vectors)

---

**Questions?** Check README_*.md files or open an issue.
