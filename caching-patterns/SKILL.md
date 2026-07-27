---
name: caching-patterns
description: Use when adding caching, configuring cache backends, or preventing cache stampedes in the Lexigram framework
---

# Caching Patterns

## Overview

Multi-backend caching behind `CacheBackendProtocol` — swap in-memory, Redis, Memcached, or custom backends via config without changing service code.

## Basic Usage

```python
from lexigram.contracts.cache import CacheBackendProtocol

class ProductService:
    def __init__(self, cache: CacheBackendProtocol):
        self.cache = cache

    async def get_price(self, product_id: str) -> Result[float, DomainError]:
        cached = await self.cache.get(f"price:{product_id}")
        if cached.is_ok():
            return Ok(float(cached.unwrap()))

        price = await self._compute_price(product_id)
        await self.cache.set(f"price:{product_id}", str(price), ttl=300)
        return Ok(price)
```

## Named Backends

```python
from typing import Annotated
from lexigram.di import Named

class ReportingService:
    def __init__(
        self,
        fast_cache: Annotated[CacheBackendProtocol, Named("session")],
        slow_cache: Annotated[CacheBackendProtocol, Named("analytics")],
    ): ...
```

## Stampede Protection

```python
# Built into Redis backend — deduplicates concurrent misses
# Only one caller recomputes; others wait for the result
await self.cache.get_or_compute(
    key="expensive:data",
    factory=compute_expensive_data,
    ttl=300,
    stale_ttl=3600,  # serve stale while re-fetching
)
```

## Key Prefixing

```yaml
# Backend handles prefix automatically from config
cache:
  backend: redis
  redis:
    url: redis://localhost:6379/0
    key_prefix: "myapp:"  # all keys get this prefix
```

## Pattern Invalidation

```python
# Invalidate all keys matching a pattern
await self.cache.invalidate_pattern("user:*:profile")
```

## Config

```yaml
cache:
  backend: redis                 # or: memory, memcached
  default_ttl: 300
  redis:
    url: redis://localhost:6379/0
    key_prefix: "myapp:"
```

## Testing

```python
from lexigram.testing import FakeCache
env.override(CacheBackendProtocol, FakeCache())
# or use the module stub:
CacheModule.stub()
```

## Common Mistakes

- No TTL on cached values — memory leak, stale data
- Caching mutable objects without keys — different users get wrong data
- Cache-aside without stale-while-revalidate — stampede on expiry
- Using default backend name when multiple caches needed — use `Named()` disambiguation
- No `FakeCache` in tests — tests hit real Redis or skip coverage
