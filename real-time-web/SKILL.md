---
name: real-time-web
description: Use when implementing real-time features with SSE, WebSocket, HTMX integration, or EventChannel in Lexigram
---

# Real-Time Web

## Overview

Lexigram supports three real-time primitives: SSE (one-way server→client), WebSocket (bidirectional), and EventChannel (pub/sub shared across processes). HTMX can consume SSE streams for declarative live updates.

## SSE with HTMX

```python
from lexigram.web import Controller, get
from lexigram.realtime import EventChannel

class LiveController(Controller):
    def __init__(self, channel: EventChannel):
        self.channel = channel

    @get("/events/stream")
    async def stream(self, request: Request):
        async with self.channel.subscribe("updates") as sub:
            async for event in sub:
                yield f"data: {event.data}\n\n"

    @post("/events/trigger")
    async def trigger(self, request: Request):
        await self.channel.publish("updates", {"status": "refreshed"})
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
from lexigram.web import websocket

class ChatHandler:
    def __init__(self, channel: EventChannel):
        self.channel = channel

    @websocket("/chat/{room}")
    async def chat(self, ws: WebSocket, room: str):
        await ws.accept()
        async with self.channel.subscribe(f"chat:{room}") as sub:
            async for msg in sub:
                await ws.send_text(msg.data)
```

## Module Registration

```python
from lexigram.realtime import RealtimeModule

AppModule.configure(
    controllers=[LiveController, ChatHandler],
    modules=[RealtimeModule.configure(channel_backend="redis")],
)
```

## Common Mistakes

- Blocking the SSE generator with sync I/O — keep it async throughout
- Using SSE for bidirectional communication — use WebSocket instead
- Missing `async with` on channel subscribe — leaks subscription handles
- Forgetting HTMX `hx-sse` swap target — events arrive but DOM never updates
- No backpressure on EventChannel — slow consumers can build unbounded buffers
