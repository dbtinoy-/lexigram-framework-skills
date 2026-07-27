---
name: testing-with-lexigram
description: Use when writing tests, creating test environments, or using stubs/fakes in the Lexigram framework
---

# Testing with Lexigram

## Overview

Lexigram's DI container makes testing straightforward: fake at the contract boundary, use `TestEnvironment` for isolation, and use `stub()` modules for full integration tests.

## TestEnvironment

```python
from lexigram.testing import TestEnvironment, FakeCache
from lexigram.contracts.cache import CacheBackendProtocol

async def test_user_service():
    env = TestEnvironment("user-service")
    env.override(CacheBackendProtocol, FakeCache())
    async with env:
        service = await env.container.resolve(UserService)
        result = await service.get_user("user-123")
        assert result.is_ok()
```

Each `TestEnvironment` is fully isolated — no global state pollution.

## Module Stubs

```python
@module(imports=[
    LLMModule.stub(),       # No-op LLM
    EventsModule.stub(),    # In-memory events
    DatabaseModule.stub(),  # In-memory DB
])
class TestModule(Module): pass

async def test_with_modules():
    async with Application.boot(modules=[TestModule]) as app:
        service = await app.container.resolve(MyService)
        result = await service.process()
        assert result.is_ok()
```

Every extension package should define `stub()` returning a `DynamicModule` with in-memory/noop backends.

## Testing Result-Returning Methods

```python
@pytest.mark.asyncio
async def test_find_user_returns_ok():
    result = await service.find_user("user-123")
    assert result.is_ok()
    assert result.unwrap().id == "user-123"

@pytest.mark.asyncio
async def test_find_user_returns_err():
    result = await service.find_user("nonexistent")
    assert result.is_err()
    assert isinstance(result.unwrap_err(), UserNotFound)
```

## Ambient Capability Override

```python
from lexigram.testing.clock import FixedClock
from lexigram.primitives import clock

with clock.use(FixedClock("2026-01-01")):
    assert clock.now().year == 2026
```

## Test Organization

```python
# tests/test_user_service.py
class TestUserService:
    @pytest.fixture
    def mock_db(self) -> AsyncMock:
        db = AsyncMock(spec=DatabaseProviderProtocol)
        db.execute = AsyncMock(return_value=[])
        return db

    @pytest.mark.asyncio
    async def test_create_user(self, mock_db: AsyncMock) -> None:
        service = UserService(db=mock_db)
        user = await service.create(email="test@example.com")
        assert user.id is not None
        mock_db.execute.assert_awaited_once()
```

### Conventions

- Files: `test_*.py`
- Classes: `Test*`
- Methods: `test_*`
- Fakes at contract boundary — mock `Protocol`, not internals
- No global state — each test is independent
- Mock clients in `tests/`, never in `src/`

## Running Tests

```bash
uv run pytest                          # Full suite
uv run pytest -m "not integration"     # Unit-only
uv run pytest -m integration           # Integration only
uv run pytest lexigram-web/tests/      # Single package
uv run pytest -k "test_user"           # Pattern match
uv run pytest --cov --cov-report=html  # Coverage
uv run pytest --cov-fail-under=80      # Coverage gate
```

### Pytest Markers

Defined in root `pyproject.toml`: `integration`, `slow`, `unit`, `e2e`, `requires_redis`, `requires_postgres`, `requires_elasticsearch`.

## Common Mistakes

- Testing with real infrastructure (DB, Redis) for unit tests — use stubs
- Forgetting `@pytest.mark.asyncio` on async tests
- Mocking implementation details instead of protocol interfaces
- Shared global state between tests — use fresh `TestEnvironment` per test
- Not calling `env.override()` before entering context
- Testing without `stub()` modules — forces full boot with real infrastructure
