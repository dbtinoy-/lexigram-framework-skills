# lexigram skills

Skill files for AI coding agents (Claude Code, OpenCode, and friends) that teach the agent how to build with the [Lexigram framework](https://github.com/dbtinoy-/lexigram). Not a python package — see this repo's `README.md` for the full explanation.

## Installation

Add to your project's `opencode.json`:

```json
{
  "plugin": ["lexigram-skills@git+https://github.com/dbtinoy-/lexigram-framework-skills.git"]
}
```

Or install globally in `~/.config/opencode/opencode.json`.

## Skills

| Skill | Use when... |
|-------|-------------|
| `ai-subsystem-quickstart` | Setting up LLM, RAG, agents, memory, MCP |
| `auth-and-security` | Authentication, authorization, guards, JWT |
| `caching-patterns` | Adding caching, configuring backends, preventing stampedes |
| `cli-code-generation` | Scaffolding code with the 42 generators |
| `cli-config-and-inspect` | Viewing config, inspecting runtime, diagnosing systems |
| `cli-database-operations` | Running migrations, seeding, backup/restore |
| `cli-project-scaffolding` | Creating projects, packages, init |
| `configuration-management` | Config, env vars, profiles, YAML |
| `creating-providers-and-modules` | Creating providers, modules, DI wiring |
| `database-repository-pattern` | Database access, repositories, domain models |
| `events-and-messaging` | CQRS, event bus, queues, outbox |
| `lexigram-ui` | Components, templates, CDN deps, static files |
| `real-time-web` | SSE, HTMX, WebSocket, EventChannel |
| `resilience-patterns` | Retry, circuit breaker, bulkhead, rate limiting |
| `testing-with-lexigram` | TestEnvironment, stubs, fakes |
| `using-result-and-error-codes` | Result[T,E], error codes, exception hierarchy |
| `web-controllers-and-routing` | HTTP endpoints, controllers, middleware, guards, CSP |
