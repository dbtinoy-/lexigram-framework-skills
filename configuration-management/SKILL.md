---
name: configuration-management
description: Use when configuring the framework, setting environment variables, managing YAML config files, or using config profiles in Lexigram
---

# Configuration Management

## Overview

Lexigram uses hierarchical YAML configuration with `LEX_` environment variable overrides and profile-based overlays. Config is discovered automatically from `application.yaml` in the project root.

## Config Precedence

```
Lowest:   Code defaults in config dataclasses
          Base YAML (application.yaml)
          Profile YAML (application.{profile}.yaml)
          LEX_ env-var overrides
Highest:  LEX_ env-var overrides with __ nesting
```

## YAML Structure

```yaml
# application.yaml
app:
  name: my-app
  env: production
  debug: false

db:
  url: postgresql+asyncpg://user:pass@localhost:5432/mydb
  pool_size: 10

cache:
  backend: redis
  redis:
    url: redis://localhost:6379/0
```

## Environment Variable Overrides

```bash
# LEX_<PACKAGE>__<FIELD> syntax — each extension declares its own prefix
LEX_SQL__BACKEND__URL=postgresql+asyncpg://prod:pass@host:5432/db
LEX_CACHE__BACKEND=redis
LEX_APP__DEBUG=true
```

Nested sections use double underscore:
```bash
LEX_SQL__POOL__MAX_SIZE=20
LEX_AI_LLM__PROVIDER=anthropic
```

## Profile Overlays

```bash
export LEX_PROFILE=development
# Loads application.yaml + application.development.yaml
```

```yaml
# application.development.yaml — overrides base values
app:
  debug: true
db:
  url: sqlite+aiosqlite:///dev.db
```

## Config in Providers

```python
from lexigram.config import ConfigSection, section_field

class MyProvider(Provider):
    config_key = "my_service"
    config_model = MyServiceConfig

    async def register(self, container: ContainerRegistrarProtocol) -> None:
        config = await container.resolve(MyServiceConfig)
        container.singleton(MyServiceProtocol, MyService(config))
```

## Quick Reference

```bash
lexigram config show              # Full resolved config
lexigram config validate          # Validate against schemas
lexigram config doctor            # Diagnose config issues
lexigram config env               # Show env vars used
lexigram config diff a.yaml b.yaml
lexigram config env-example       # Generate .env.example
```

## Common Mistakes

- Assuming env vars override YAML — they do, but `LEX_` prefix is required
- Using wrong separator — double underscore `__` for nesting, not `.`
- Forgetting `LEX_PROFILE` — defaults to `production`, may surprise in dev
- Embedding secrets in `application.yaml` — use env vars or a secrets backend
