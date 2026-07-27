---
name: using-result-and-error-codes
description: Use when handling domain errors, adding exception classes, or working with the LEX_ERR_* error code system in Lexigram
---

# Using Result and Error Codes

## Overview

Lexigram uses a two-track error strategy: `Result[T, E]` for expected domain failures, exceptions for unexpected infrastructure failures. Every exception carries a `LEX_ERR_<DOMAIN>_<NNN>` code.

## Two-Track Strategy

| Use `Result[T, E]` | Use Exceptions |
|---|---|
| User not found, validation failed | Database connection lost |
| Payment declined, permission denied | Network timeout, OOM |
| Business rule violation | Missing API key |
| LLM content filter triggered | Serialization bug |

## Result API

```python
from lexigram.result import Result, Ok, Err
from lexigram.result.utils import as_result, collect, partition

result = await service.find_user("123")

result.is_ok() / result.is_err()
result.unwrap() / result.unwrap_err()   # only after is_ok/ is_err check
result.unwrap_or(default) / result.unwrap_or_else(fn)

# Sync transforms
result.map_sync(lambda u: u.email)
result.and_then_sync(validate_user)

# Async transforms
await result.map(load_profile)
await result.and_then(create_order)

# Exhaustive match
msg = result.match(
    ok=lambda u: f"Found {u.name}",
    err=lambda e: f"Error: {e}",
)

# Utils
result.expect("Should have found user")
result.to_optional()
result.inspect(lambda u: ...)

# Chaining helpers (lexigram.result.utils)
@as_result(ValueError, KeyError)
async def parse(data: str) -> int: ...

results = [Ok(1), Err("bad"), Ok(2)]
all_ok = collect(results)          # Result[list[int], str]
oks, errs = partition(results)     # ([1, 2], ["bad"])
```

### Prohibited Patterns

```python
# ❌ Never unwrap() without checking
user = result.unwrap()

# ❌ Never wrap infrastructure errors in Result
try:
    data = await db.query(sql)
except DatabaseError as e:
    return Err(e)   # Let exceptions propagate

# ❌ Never use Result for infallible operations
def add(a: int, b: int) -> Result[int, Never]:
    return Ok(a + b)

# ❌ Never use Any as error type
async def execute() -> Result[SkillResult, Any]: ...
```

## Error Code System

Every exception has a `_code` attribute: `LEX_ERR_<DOMAIN>_<NNN>`.

**576 registered codes across 40 packages** — see `REF_ERROR_CODES.md`.

### Hierarchy

```
lexigram-contracts                    Extension Package
──────────────────                    ────────────────
LEX_ERR_AI_001 AIError               LEX_ERR_LLM_002 LLMError(AIError)
                                     LEX_ERR_LLM_003 LLMAuthenticationError(LLMError)
                                     
LEX_ERR_AGT_001 AgentError           LEX_ERR_AGT_004 AgentConfigurationError(AgentError)
                                     LEX_ERR_AGT_005 AgentExecutionError(AgentError)
```

### Creating New Exceptions

```python
# In lexigram-contracts for shared exceptions
# Use an unused code from the domain's range (see REF_ERROR_CODES.md for gaps)
LEX_ERR_CACHE_012 = "LEX_ERR_CACHE_012"

class CacheCustomError(CacheError):
    _code = LEX_ERR_CACHE_012
    """Custom cache error."""

# In extension packages for leaf exceptions
LEX_ERR_CACHE_013 = "LEX_ERR_CACHE_013"

class CacheSpecificError(CacheCustomError):
    _code = LEX_ERR_CACHE_013
    """Specific failure scenario."""
```

### Rules

- Base domain exceptions in `lexigram-contracts`, leaf exceptions in extension packages
- One definition per code across the entire monorepo
- No exception defined in two places
- Extensions extend contracts base (`class MyError(ContractsBaseError)`)
- Every package needs a base exception class

## Domain Tags (67 domains)

Common tags: `ADMIN` (30), `AGT` (11), `AUTH` (28), `CACHE` (15), `DB` (11), `DI` (11), `DOM` (9), `EVT` (23), `LLM` (26), `MCP` (8), `RAG` (14), `SEC` (12), `SQL` (37), `WF` (22).

## Common Mistakes

- Defining the same error code in two packages
- Using `Result` for infrastructure failures (let them propagate)
- Calling `unwrap()` without `is_ok()` check
- Returning `Result` from `__init__` or lifecycle hooks (`boot`, `shutdown`)
- Using `Any` as the error type parameter
