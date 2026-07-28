---
name: events-and-messaging
description: Use when implementing event-driven patterns, CQRS, or message queue integration in the Lexigram framework
---

# Events and Messaging

## Overview

Lexigram provides three messaging primitives: commands (one handler), events (many handlers), and queues (async pub/sub). Built on `lexigram-events` and `lexigram-queue`.

## Commands (CQRS)

```python
from lexigram.events import Command, CommandHandlerProtocol

class CreateOrder(Command):
    user_id: str
    items: list[Item]

class CreateOrderHandler(CommandHandlerProtocol[CreateOrder, Result[Order, DomainError]]):
    def __init__(self, repo: OrderRepositoryProtocol):
        self.repo = repo

    async def handle(self, cmd: CreateOrder) -> Result[Order, DomainError]:
        order = Order(user_id=cmd.user_id, items=cmd.items)
        return await self.repo.save(order)
```

## Events (Pub/Sub)

```python
from lexigram.events import DomainEvent, event_handler

class OrderCreated(DomainEvent):
    order_id: str
    user_id: str

@event_handler(OrderCreated)
async def send_confirmation(event: OrderCreated, mailer: MailerProtocol) -> None:
    await mailer.send(event.user_id, "Order confirmed")
```

## Buses

```python
from lexigram.events import CommandBus, EventBus

bus = await container.resolve(CommandBus)
result = await bus.dispatch(CreateOrder(user_id="u1", items=[...]))

bus = await container.resolve(EventBus)
result = await bus.publish(OrderCreated(order_id="o1", user_id="u1"))
```

## Message Queues

```python
from lexigram.queue import QueueProtocol, BusMessage

queue = await container.resolve(QueueProtocol)
await queue.publish("orders.new", BusMessage(payload={"id": "o1"}))

class OrderConsumer(MessageConsumer):
    topic = "orders.new"
    async def handle(self, msg: BusMessage) -> None:
        order_id = msg.payload["id"]
        await self.process(order_id)
```

## Transactional Outbox

```python
from lexigram.queue import TransactionalOutbox

outbox = TransactionalOutbox(queue)
outbox.stage("orders.created", BusMessage(payload={"order_id": order.id}))
await outbox.flush()
```

## Quick Reference

| Pattern | Class | Bus |
|---------|-------|-----|
| Command (1 handler) | `Command`, `CommandHandlerProtocol[T, TResult]` | `CommandBus.dispatch()` |
| Event (N handlers) | `DomainEvent`, `@event_handler` | `EventBus.publish()` |
| Queue pub/sub | `QueueProtocol`, `MessageConsumer` | `queue.publish()/subscribe()` |
| Outbox | `TransactionalOutbox` | `outbox.stage()` / `outbox.flush()` |

## Common Mistakes

- Using events where commands fit — commands have one handler, events have many
- Blocking in async event handlers — handlers run sequentially per bus
- Forgetting `@event_handler` decorator — handlers aren't auto-discovered
- Publishing outside a DB transaction with outbox — events may be lost on rollback
