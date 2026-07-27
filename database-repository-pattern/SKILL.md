---
name: database-repository-pattern
description: Use when setting up database access, creating repositories, running migrations, or defining domain models in the Lexigram framework
---

# Database Repository Pattern

## Overview

Async SQL with protocol-based repositories. Domain models are plain dataclasses (not ORM entities). Infrastructure-layer implementations handle ORM mapping — domain code never sees it.

## Repository Pattern

```python
# Domain layer — pure protocol (in contracts)
class UserRepositoryProtocol(Protocol):
    async def find(self, user_id: str) -> Result[User, NotFoundError]: ...
    async def save(self, user: User) -> Result[User, DomainError]: ...
    async def delete(self, user_id: str) -> Result[None, DomainError]: ...

# Infrastructure layer — concrete implementation
class SqlUserRepository:
    def __init__(self, db: DatabaseProviderProtocol):
        self.db = db

    async def find(self, user_id: str) -> Result[User, NotFoundError]:
        async with self.db.scoped_context() as conn:
            row = await conn.fetch_row("SELECT * FROM users WHERE id = $1", user_id)
            if not row:
                return Err(UserNotFoundError(user_id))
            return Ok(User(id=row["id"], name=row["name"], email=row["email"]))

# DI binding
container.singleton(UserRepositoryProtocol, SqlUserRepository)
```

## Domain Models

```python
from lexigram.domain import DomainModel

class User(DomainModel):
    id: str
    name: str
    email: str
```

Models are frozen dataclasses by default. Not SQLAlchemy mapped objects — mapping lives in infrastructure only.

## Generic Repository

```python
from lexigram.sql import GenericRepository

class UserRepo(GenericRepository[User]):
    table = "users"
    model_cls = User
```

## Migrations

```bash
lexigram db init                        # Create migrations directory
lexigram db migrate "add user table"    # Auto-generate migration
lexigram db upgrade                      # Apply pending migrations
lexigram db downgrade                    # Revert
lexigram db status / history             # Migration state
```

## Config

```yaml
db:
  url: postgresql+asyncpg://user:pass@localhost:5432/mydb
  pool_size: 10
  max_overflow: 20
  echo: false          # SQL logging
```

Use async drivers: `postgresql+asyncpg://`, `mysql+aiomysql://`, `sqlite+aiosqlite://`.

## Testing

```python
# Unit test with fake repo
class FakeUserRepo:
    def __init__(self):
        self._users: dict[str, User] = {}

    async def find(self, user_id: str) -> Result[User, NotFoundError]:
        user = self._users.get(user_id)
        if not user:
            return Err(UserNotFoundError(user_id))
        return Ok(user)
```

## Common Mistakes

- Domain models extending SQLAlchemy `Base` — keeps ORM out of domain
- Business logic in repository — repositories query/store, services orchestrate
- Using sync drivers in async context — deadlock risk
- Not wrapping transactions — use `scoped_context()` or `unit_of_work`
- Mixing migration state across environments — always version-control `migrations/`
