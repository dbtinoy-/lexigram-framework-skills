---
name: lexigram-ui
description: Use when serving UI components, templates, static files, or configuring CDN dependencies in a Lexigram application
---

# Lexigram UI

## Overview

Lexigram-ui provides component-based server-side rendering with JinjaX components, static file serving, CDN dependency management, and HTMX integration.

## Component Pattern

```python
from lexigram.ui import Component, component

@component("dashboard/stats")
class StatsComponent(Component):
    template = "components/stats.html.jinja"

    async def context(self, request: Request) -> dict:
        return {
            "users": await self.repo.count(),
            "revenue": await self.repo.revenue_today(),
        }
```

Component template (`components/stats.html.jinja`):

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
from lexigram.ui import StaticFiles

AppModule.configure(
    middleware=[StaticFiles(static_dir="./static", url_prefix="/static")],
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
- Forgetting `StaticFiles` middleware — static assets return 404
- Putting business logic in component `context()` — delegate to services
- Missing HTMX script tag — dynamic features silently fail
