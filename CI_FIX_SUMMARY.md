# 🔧 CI Fix - pytest-asyncio Missing

## Problem
CI was failing with error:
```
async def functions are not natively supported.
You need to install a suitable plugin for your async framework
```

## Root Cause
The CI workflow was installing `pytest pytest-cov` but **missing `pytest-asyncio`**, which is required to run async test functions with `@pytest.mark.asyncio` decorators.

## Solution
Updated `.github/workflows/ci.yml` line 33:

```diff
- uv pip install --system mypy flake8 pytest pytest-cov
+ uv pip install --system mypy flake8 pytest pytest-cov pytest-asyncio
```

## Verification
- ✅ Local tests pass (16/16) with pytest-asyncio installed
- ✅ CI should now pass with this dependency

## Commit
```
44a43fa - fix: install pytest-asyncio in CI workflow
```

## Expected CI Result
- 16/16 tests passing
- 4/4 test_embeddings (sync tests)
- 12/12 CRUD tests (async tests with @pytest.mark.asyncio)

---
**Status:** ✅ Ready for CI validation
