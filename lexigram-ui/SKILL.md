---
name: lexigram-ui
description: Use when serving UI components, templates, static files, or configuring CDN dependencies in a Lexigram application
---

# Lexigram UI

## Overview

Lexigram-ui provides component-based server-side rendering with JinjaX components, static file serving, CDN dependency management, and HTMX integration.

## Component Pattern

```python
from lexigram.ui import component
from lexigram.ui.protocols import RenderableProtocol

@component("dashboard/stats")
async def stats_component(request: Request) -> dict:
    repo = await request.state.container.resolve(UserRepositoryProtocol)
    return {
        "users": await repo.count(),
        "revenue": await repo.revenue_today(),
    }
```

```html
<div class="grid grid-cols-2 gap-4">
  <div class="stat-card">
    <span class="stat-label">Users</span>
    <span class="stat-value">{{ users }}</span>
  </div>
  <div class="stat-card">
    <span class="stat-label">Revenue</span>
    <span class="stat-value">${{ revenue }}</span>
  </div>
</div>
```

## CDN Dependencies

```yaml
ui:
  cdn:
    htmx: https://unpkg.com/htmx.org@2.0.0
    alpine: https://unpkg.com/alpinejs@3.0.0
    tailwind: https://cdn.tailwindcss.com
  static_dir: ./static
  templates_dir: ./templates
```

Dependencies are injected into every rendered page via `<head>` automatically.

## Static Files

```python
from lexigram.web.middleware.static import StaticFilesMiddleware

AppModule.configure(
    middleware=[StaticFilesMiddleware(static_dir="./static", url_prefix="/static")],
)
```

## Module Registration

```python
from lexigram.ui import UIModule

async with Application.boot(modules=[
    UIModule.configure(ui_config),
]) as app:
    ...
```

## Common Mistakes

- Serving templates outside the configured `templates_dir` — raises `TemplateNotFound`
- Embedding CDN URLs in templates — use `cdn:` config for centralized management
- Forgetting `StaticFilesMiddleware` — static assets return 404
- Putting business logic in component `context()` — delegate to services
- Missing HTMX script tag — dynamic features silently fail
