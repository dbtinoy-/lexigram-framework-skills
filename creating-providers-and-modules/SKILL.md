---
name: creating-providers-and-modules
description: Use when creating new extension packages, adding providers, or defining modules in the Lexigram framework
---

# Creating Providers and Modules

## Overview

Providers wire services into the DI container. Modules group providers and enforce boundary visibility. Together they form the composition root.

## Core Pattern

```
Provider  → registers/boots/shuts down one bounded concern
Module    → groups providers, defines imports/exports
```

## Provider Lifecycle

```python
from lexigram.di import Provider
from lexigram.contracts.di import ContainerRegistrarProtocol, ContainerResolverProtocol
from lexigram.contracts.core.health import HealthCheckResult, HealthStatus

class MyProvider(Provider):
    name = "my_provider"
    priority = ProviderPriority.NORMAL

    async def register(self, container: ContainerRegistrarProtocol) -> None:
        container.singleton(MyProtocol, MyImpl)
        container.transient(OtherProtocol, lambda: OtherImpl(...))

    async def boot(self, container: ContainerResolverProtocol) -> None:
        svc = await container.resolve(MyProtocol)
        await svc.connect()

    async def shutdown(self) -> None:
        await self._cleanup()

    async def health_check(self, timeout: float = 5.0) -> HealthCheckResult:
        return HealthCheckResult(component=self.name, status=HealthStatus.HEALTHY)
```

### Rules

- `register()` gets `ContainerRegistrarProtocol` — no resolution
- `boot()` gets `ContainerResolverProtocol` — no registration
- No business logic on Provider classes
- All I/O in boot/shutdown is async

### Provider Priorities

| Priority | Value | When |
|----------|-------|------|
| `CRITICAL` | 0 | Logging, error handling |
| `INFRASTRUCTURE` | 10 | Database, cache, queues |
| `SECURITY` | 20 | Auth middleware, encryption |
| `NORMAL` | 30 | Default |
| `DOMAIN` | 50 | Business services |
| `PRESENTATION` | 80 | Controllers, templates |
| `COMMS` | 90 | WebSocket, SSE |
| `LOW` | 100 | Admin UI, analytics |

Shutdown runs in reverse priority order.

## Module Patterns

### Static Module (no config)

```python
from lexigram.di import module, Module

@module(providers=[MyProvider], imports=[ConfigModule], exports=[MyProtocol])
class MyModule(Module):
    pass
```

### Dynamic Module (with config)

```python
from lexigram.di import module, Module, DynamicModule

@module()
class MyModule(Module):
    @classmethod
    def configure(cls, config: MyConfig | None = None) -> DynamicModule:
        return DynamicModule(
            module=cls,
            providers=[MyProvider(config=config)],
            exports=[MyProtocol],
        )

    @classmethod
    def stub(cls, config: MyConfig | None = None) -> DynamicModule:
        return DynamicModule(
            module=cls,
            providers=[MyStubProvider(config=config)],
            exports=[MyProtocol],
        )
```

Three factory conventions: `configure()` (production), `scope()` (sub-scope), `stub()` (testing).

## Package File Layout

```
lexigram-mypackage/
├── src/lexigram/mypackage/
│   ├── __init__.py         # Lazy exports only
│   ├── config.py           # Config dataclasses
│   ├── module.py           # Module entry point
│   ├── exceptions.py       # Leaf exceptions
│   ├── di/
│   │   └── provider.py     # Provider(s)
│   └── ...                 # Implementation
├── tests/
└── pyproject.toml
```

## Common Mistakes

- Calling `register()` after container freeze — raises `ContainerFrozenError`
- Resolving in `register()` — use `boot()` instead
- Business logic on Provider — belongs in services, not providers
- Forgetting `exports` in DynamicModule — consumers can't resolve the type
- Not defining `stub()` — forces test modules to use real implementations
