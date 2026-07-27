---
name: resilience-patterns
description: Use when adding retry logic, circuit breakers, rate limiting, or fault-tolerance patterns in the Lexigram framework
---

# Resilience Patterns

## Overview

Lexigram provides composable fault-tolerance primitives: retry, circuit breaker, bulkhead, rate limiter, timeout, and fallback. Patterns compose into a `ResiliencePipeline`.

## Decorators

```python
from lexigram.resilience import retry, circuit_breaker, bulkhead, timeout

@retry(max_attempts=3, delay=1.0, backoff=2.0)
@circuit_breaker(failure_threshold=5, recovery_timeout=30)
@bulkhead(max_concurrent=10, max_queue=20)
@timeout(seconds=30)
async def call_external_api(payload: dict) -> Result[Response, DomainError]:
    return await self.client.post(payload)
```

## Programmatic API

```python
from lexigram.resilience import RetryConfig, CircuitBreaker, RetryPolicy

# Retry
config = RetryConfig(max_attempts=3, delay=1.0, backoff=2.0, jitter=True)
policy = RetryPolicy(config)
result = await policy.execute(lambda: fetch_data())

# Circuit breaker
cb = CircuitBreaker(failure_threshold=5, recovery_timeout=30.0)
async with cb:
    result = await call_service()

# Resilience pipeline
from lexigram.resilience import ResiliencePipeline

pipeline = ResiliencePipeline(
    retry=RetryConfig(max_attempts=3),
    circuit_breaker=CircuitBreaker(failure_threshold=5, recovery_timeout=30),
    timeout=15.0,
)
result = await pipeline.run(fetch_data)
```

## Composition Order

```
Request → Bulkhead → Circuit Breaker → Retry → Timeout → Fallback → Service
```

## Quick Reference

| Pattern | Decorator | When to Use |
|---------|-----------|-------------|
| Retry | `@retry(config)` | Transient failures (network, 503) |
| Circuit Breaker | `@circuit_breaker(config)` | Downstream is down — fail fast |
| Bulkhead | `@bulkhead(config)` | Limit concurrent calls |
| Rate Limiter | `RateLimiter` | Throttle request rate |
| Timeout | `@timeout(seconds)` | Hard deadline for slow calls |
| Fallback | `@fallback(fn)` | Return degraded response on failure |

## Config

```yaml
resilience:
  retry:
    max_attempts: 3
    delay: 1.0
    backoff: 2.0
    jitter: true
  circuit_breaker:
    failure_threshold: 5
    recovery_timeout: 30.0
```

## Common Mistakes

- Retrying non-idempotent operations — can cause duplicate charges/actions
- Placing retry outside circuit breaker — retries keep hammering a dead service
- No jitter on retry delay — thundering herd on recovery
- Using decorators on sync functions — all resilience is async-only
- Missing fallback — user gets 500 instead of a degraded response
