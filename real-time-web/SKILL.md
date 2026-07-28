---
name: real-time-web
description: Use when implementing real-time features with SSE, WebSocket, or HTMX integration in Lexigram
---

# Real-Time Web

## Overview

Lexigram supports two real-time primitives: SSE (one-way server→client) and WebSocket (bidirectional). HTMX can consume SSE streams for declarative live updates.

## SSE with HTMX

```python
from lexigram.web import Controller, get, post
from lexigram.web.sse.handler import AbstractSSEHandler

class LiveController(Controller):
    def __init__(self, sse: AbstractSSEHandler):
        self.sse = sse

    @get("/events/stream")
    async def stream(self, request: Request):
        return await self.sse.stream()

    @post("/events/trigger")
    async def trigger(self, request: Request):
        await self.sse.push({"status": "refreshed"})
        return {"ok": True}
```

HTMX client:

```html
<div hx-sse="connect:/events/stream swap:message">
  <div hx-get="/partials/dashboard" hx-trigger="load">
    Loading…
  </div>
</div>
```

## WebSocket Handler

```python
from lexigram.web.websocket.decorators import websocket_handler

class ChatHandler:
    @websocket_handler("/chat/{room}")
    async def chat(self, ws: WebSocket, room: str):
        await ws.accept()
        async for message in ws.iter_text():
            await ws.send_text(f"echo: {message}")
```

## Common Mistakes

- Blocking the SSE generator with sync I/O — keep it async throughout
- Using SSE for bidirectional communication — use WebSocket instead
- Forgetting HTMX `hx-sse` swap target — events arrive but DOM never updates
