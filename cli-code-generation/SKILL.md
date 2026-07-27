---
name: cli-code-generation
description: Use when scaffolding code components like controllers, services, models, or any of the 42 lexigram gen generators
---

# CLI Code Generation

## Overview

`lexigram gen` provides 42 code generators that scaffold components with proper DI wiring, module registration, and protocol bindings — no manual boilerplate.

## Basic Usage

```bash
lexigram gen list                           # List all available generators

# Core patterns
lexigram gen model Product                  # SQLAlchemy model
lexigram gen repository ProductRepo         # DB repository with queries
lexigram gen service ProductService         # Service with unit of work
lexigram gen controller ProductController   # Web controller with routes
lexigram gen resource Product               # Full RESTful CRUD resource
lexigram gen provider MyProvider            # DI provider
lexigram gen test ProductServiceTest        # Test scaffold

# Web & API
lexigram gen middleware AuthMiddleware       # Web middleware
lexigram gen graphql ProductSchema           # GraphQL schema + resolvers
lexigram gen webhook stripe_payment          # Webhook handler
lexigram gen websocket chat                  # WebSocket handler
lexigram gen api_client PaymentGateway       # External API client

# Data & Infrastructure
lexigram gen cache_repo ProductCache         # Cache-backed repo with TTL
lexigram gen storage_driver S3               # File storage backend
lexigram gen search_index Products           # Search index with backend
lexigram gen vector_collection Documents     # Vector collection
lexigram gen document_repo Orders            # NoSQL document repo

# Events & Workflows
lexigram gen event_handler OrderPlaced       # Event handler with bus registration
lexigram gen event OrderPlaced               # Domain event class
lexigram gen command CreateOrder             # CQRS command handler
lexigram gen query GetOrder                  # CQRS query handler
lexigram gen message_consumer order_worker   # Message consumer with queue routing
lexigram gen task process_payment            # Background task
lexigram gen workflow_def order_fulfillment  # Workflow with steps + transitions
lexigram gen pipeline data_pipeline          # Sequential pipeline stages
lexigram gen saga_step reserve_inventory     # Saga step with compensation
lexigram gen saga order_saga                 # Saga orchestrator

# AI & MCP
lexigram gen mcp-server my-tools             # Standalone MCP server
lexigram gen mcp-controller MyTool           # MCP controller with tool/resources
lexigram gen feature_flag dark_mode          # Feature flag definition
lexigram gen metric request_latency          # Custom metric with backend
lexigram gen notification_template welcome   # Notification template

# Admin
lexigram gen admin_resource ProductAdmin     # Admin panel resource
lexigram gen admin_action BulkPublish        # Custom admin action

# Other
lexigram gen filter ProductFilter            # Query filter for models
lexigram gen seeder ProductSeeder            # DB seeder for test data
lexigram gen health db_health                # Database health check
lexigram gen dataloader ProductLoader        # GraphQL DataLoader (N+1 fix)
lexigram gen tenant_resolver header          # Custom tenant resolver
lexigram gen guard ProductGuard              # Authorization guard
lexigram gen auth_guard ProductGuard         # Auth guard
lexigram gen auth_policy ProductPolicy       # Auth policy
lexigram gen tenant_resolver header          # Custom tenant resolver
lexigram gen provider MyProvider             # Generate provider
```

## Typical Workflow

```bash
lexigram gen model Product
lexigram gen repository ProductRepo
lexigram gen service ProductService
lexigram gen resource Product        # controller + routes
# Then register in your module
```

## Post-Generation

After running a generator, you typically need to:
- Register the generated provider in your module (`configure()`)
- Add any config sections to `application.yaml`
- Run `lexigram db upgrade` if a migration was created

## Common Mistakes

- Running `gen` outside a project — CLI needs project context
- Multiple generators for overlapping concerns — `gen resource` bundles controller + model + service
- Forgetting to register generated providers — generators scaffold files but don't auto-register
- Running `gen mcp-server` vs `gen mcp-controller` — server is standalone, controller integrates into an existing app
