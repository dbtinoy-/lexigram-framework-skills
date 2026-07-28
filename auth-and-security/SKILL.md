---
name: auth-and-security
description: Use when adding authentication, authorization, guards, or security middleware in a Lexigram application
---

# Auth and Security

## Overview

Lexigram-auth provides JWT-based authentication, role-based access control (RBAC), and integration with the web layer's guard system. Auth flows are provider-configured and injectable via `AuthProtocol`.

## Core Pattern

```python
from lexigram.auth import AuthProtocol, UserSession, JWTConfig

class AuthService:
    def __init__(self, auth: AuthProtocol):
        self.auth = auth

    async def login(self, email: str, password: str) -> Result[str, AuthError]:
        session = await self.auth.authenticate(email, password)
        return session.map_sync(lambda s: s.token)

    async def require_admin(self, token: str) -> Result[UserSession, AuthError]:
        return await self.auth.verify(token, roles=["admin"])
```

## Guards

```python
from lexigram.web import AuthGuard

class AdminGuard(AuthGuard):
    async def can_activate(self, request) -> bool:
        session = await request.auth.get_session()
        return session is not None and "admin" in session.roles

@use_guards(AuthGuard, AdminGuard)
@get("/admin/users")
async def admin_list(self, request: Request):
    return {"users": await self.repo.find_all()}
```

## Provider Config

```yaml
auth:
  jwt_secret: ${JWT_SECRET}
  jwt_algorithm: HS256
  access_token_ttl: 3600
  refresh_token_ttl: 604800
  password_hashing: bcrypt
```

## Module Registration

```python
from lexigram.auth import AuthModule

async with Application.boot(modules=[
    AuthModule.configure(auth_config),
]) as app:
    auth = await app.container.resolve(AuthProtocol)
```

## Common Mistakes

- Storing JWT secrets in code — use `$` env-var references in YAML
- Forgetting `AuthGuard` on admin routes — unprotected endpoints
- Using sync password hashing in async handlers — blocks event loop
- Not configuring refresh token TTL — users forced to re-login hourly
- Returning tokens in error responses — leak credentials in logs
