---
name: web-controllers-and-routing
description: Use when creating HTTP endpoints, controllers, middleware, or web routes in the Lexigram framework
---

# Web Controllers and Routing

## Overview

Lexigram-web provides an async-first web layer on Starlette. Controllers group related routes via decorators, with full DI injection and middleware guards.

## Controller Pattern

```python
from lexigram.web import Controller, get, post, put, delete
from lexigram.web import Request

class UserController(Controller):
    def __init__(self, repo: UserRepositoryProtocol):
        self.repo = repo

    @get("/users")
    async def list_all(self, request: Request):
        result = await self.repo.find_all()
        return {"users": [u.to_dict() for u in result]}

    @get("/users/{user_id}")
    async def get_one(self, request: Request, user_id: str):
        result = await self.repo.find(user_id)
        return result.match(
            ok=lambda u: {"user": u.to_dict()},
            err=lambda e: ({"error": str(e)}, 404),
        )

    @post("/users")
    async def create(self, request: Request):
        data = await request.json()
        result = await self.repo.create(data)
        return result.match(
            ok=lambda u: ({"user": u.to_dict()}, 201),
            err=lambda e: ({"error": str(e)}, 400),
        )

    @delete("/users/{user_id}")
    async def delete(self, user_id: str):
        await self.repo.delete(user_id)
        return {"ok": True}
```

## Guards and Middleware

```python
from lexigram.web.security import use_guards, AuthGuard
from lexigram.contracts.web.guard import GuardProtocol

class AdminGuard(GuardProtocol):
    async def can_activate(self, context) -> bool:
        user = getattr(context.state, "user", None)
        return user is not None and "admin" in user.roles

@use_guards(AuthGuard, AdminGuard)
@get("/admin/dashboard")
async def dashboard(self, request: Request):
    return {"data": "sensitive"}
```

## Module Registration

```python
from lexigram.web import WebModule

class AppModule(Module):
    @classmethod
    def configure(cls) -> DynamicModule:
        return WebModule.configure(
            controllers=[UserController],
            host="0.0.0.0",
            port=8000,
        )
```

## Quick Reference

| Decorator | Method | Path Example |
|-----------|--------|-------------|
| `@get(path)` | GET | `@get("/users/{id}")` |
| `@post(path)` | POST | `@post("/users")` |
| `@put(path)` | PUT | `@put("/users/{id}")` |
| `@delete(path)` | DELETE | `@delete("/users/{id}")` |
| `@patch(path)` | PATCH | `@patch("/users/{id}")` |
| `@use_guards(*guards)` | any | `@use_guards(AuthGuard)` |

## Content Security Policy

CSP is configured via `CSPPolicy` dataclass and applied through `SecurityHeadersMiddleware`, not a standalone middleware class.

```python
from lexigram.web.security import CSPPolicy
from lexigram.web.security.headers import SecurityHeadersMiddleware

class AppModule(Module):
    @classmethod
    def configure(cls) -> DynamicModule:
        return DynamicModule(
            module=cls,
            providers=[
                WebProvider(
                    controllers=[UserController],
                    middleware=[SecurityHeadersMiddleware(
                        csp=CSPPolicy(
                            default_src=["'self'"],
                            script_src=["'self'", "https://unpkg.com"],
                            style_src=["'self'", "https://cdn.tailwindcss.com"],
                            img_src=["'self'", "data:"],
                            connect_src=["'self'", "ws://localhost:8000"],
                        ),
                    )],
                    host="0.0.0.0",
                    port=8000,
                ),
            ],
        )
```

## Common Mistakes

- Blocking I/O in async handlers — use `await` on all calls
- Returning exceptions directly — return `(body, status_code)` tuple
- Forgetting to register controllers in `WebModule.configure()`
- Business logic in controllers — delegate to services
- Missing `CSPPolicy` on HTMX/SSE endpoints — inline event handlers blocked by default
- Overly permissive `script-src: 'unsafe-inline'` — defeats CSP purpose
