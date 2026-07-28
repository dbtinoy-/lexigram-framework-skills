---
name: resilience-patterns
description: Use when adding retry logic, circuit breakers, rate limiting, or fault-tolerance patterns in the Lexigram framework
---

# Resilience Patterns

## Overview

Lexigram provides composable fault-tolerance primitives: retry, circuit breaker, bulkhead, rate limiter, and timeout. Patterns compose into a `ResiliencePipeline`.

## Decorators

All decorators take config objects, not raw keyword arguments.

```python
from lexigram.resilience import retry, circuit_breaker, bulkhead, with_timeout
from lexigram.resilience import RetryConfig, CircuitBreakerConfig, BulkheadConfig, TimeoutConfig, CircuitBreakerRegistry

@retry(RetryConfig(max_attempts=3, base_delay=1.0, backoff_factor=2.0))
@circuit_breaker("external-api", registry=CircuitBreakerRegistry(), config=CircuitBreakerConfig(failure_threshold=5, recovery_timeout=30))
@bulkhead(BulkheadConfig(max_concurrent=10, queue_size=20))
@with_timeout(TimeoutConfig(timeout=30.0))
async def call_external_api(payload: dict) -> Result[Response, DomainError]:
    return await self.client.post(payload)
```

## Programmatic API

```python
from lexigram.resilience import (
    RetryConfig, CircuitBreaker, RetryPolicy,
    CircuitBreakerConfig, CircuitBreakerRegistry,
    ResiliencePipeline, TimeoutConfig,
)

# Retry
config = RetryConfig(max_attempts=3, base_delay=1.0, backoff_factor=2.0, jitter=True)
policy = RetryPolicy(config)
result = await policy.execute(lambda: fetch_data())

# Circuit breaker — use protect() as context manager
cb = CircuitBreaker(CircuitBreakerConfig(failure_threshold=5, recovery_timeout=30.0))
async with cb.protect():
    result = await call_service()

# Resilience pipeline
from lexigram.resilience import ResiliencePipeline

pipeline = ResiliencePipeline(
    retry_config=RetryConfig(max_attempts=3),
    circuit_config=CircuitBreakerConfig(failure_threshold=5, recovery_timeout=30),
    timeout_config=TimeoutConfig(timeout=15.0),
)
result = await pipeline.execute(fetch_data)
```

## Composition Order

```
Request → Bulkhead → Circuit Breaker → Retry → Timeout → Service
```

## Quick Reference

| Pattern | Decorator | When to Use |
|---------|-----------|-------------|
| Retry | `@retry(config)` | Transient failures (network, 503) |
| Circuit Breaker | `@circuit_breaker(name, ...)` | Downstream is down — fail fast |
| Bulkhead | `@bulkhead(config)` | Limit concurrent calls |
| Rate Limiter | `RateLimiter` | Throttle request rate |
| Timeout | `@with_timeout(config)` | Hard deadline for slow calls |

## Config

```yaml
resilience:
  retry:
    max_attempts: 3
    base_delay: 1.0
    backoff_factor: 2.0
    jitter: true
  circuit_breaker:
    failure_threshold: 5
    recovery_timeout: 30.0
```

## Common Mistakes

- Retrying non-idempotent operations — can cause duplicate charges/actions
- Placing retry outside circuit breaker — retries keep hammering a dead service
- No jitter on retry delay — thundering herd on recovery
- Not using `_sync` variant decorators for sync functions
- Missing fallback — user gets 500 instead of a degraded response
