---
name: auth-and-security
description: Use when adding authentication, authorization, guards, or security middleware in a Lexigram application
---

# Auth and Security

## Overview

Lexigram-auth provides JWT-based authentication, role-based access control (RBAC), and integration with the web layer's guard system. Auth flows are provider-configured and injectable via `AuthenticatorProtocol`.

## Core Pattern

```python
from lexigram.contracts.auth import AuthenticatorProtocol

class AuthService:
    def __init__(self, auth: AuthenticatorProtocol):
        self.auth = auth

    async def login(self, email: str, password: str) -> Result[str, AuthError]:
        from lexigram.auth.authn import AuthenticationService
        svc = AuthenticationService(self.auth)
        result = await svc.authenticate(email, password)
        return result.map_sync(lambda t: t.access_token)

    async def require_admin(self, token: str) -> Result[bool, AuthError]:
        result = await self.auth.verify_token(token)
        return result.map_sync(lambda vt: "admin" in vt.claims.get("roles", []))
```

## Guards

```python
from lexigram.web.security import AuthGuard, use_guards
from lexigram.contracts.web.guard import GuardProtocol

class AdminGuard(GuardProtocol):
    async def can_activate(self, context) -> bool:
        user = getattr(context.state, "user", None)
        return user is not None and "admin" in user.roles

@use_guards(AuthGuard, AdminGuard)
@get("/admin/users")
async def admin_list(self, request: Request):
    return {"users": await self.repo.find_all()}
```

## Provider Config

```yaml
auth:
  secret_key: ${JWT_SECRET}
  token:
    algorithm: HS256
    access_token_expire: 60m
    refresh_token_expire: 7d
```

## Module Registration

```python
from lexigram.auth import AuthModule
from lexigram.contracts.auth import AuthenticatorProtocol

async with Application.boot(modules=[
    AuthModule.configure(config=auth_config),
]) as app:
    auth = await app.container.resolve(AuthenticatorProtocol)
```

## Common Mistakes

- Storing JWT secrets in code — use `$` env-var references in YAML
- Forgetting `AuthGuard` on admin routes — unprotected endpoints
- Using sync password hashing in async handlers — blocks event loop
- Not configuring refresh token TTL — users forced to re-login hourly
- Returning tokens in error responses — leak credentials in logs
