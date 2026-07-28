# lexigram skills

*how Lexigram teaches the AI in your editor to build with it.*

These are skill files for AI coding agents — Claude Code, OpenCode, and friends. Drop them into your agent, and when you ask it to wire a provider, scaffold a controller, or set up RAG, the agent reaches for the same patterns you would.

> **important — this is not a python package.** `lexigram-skills` is not on PyPI. `uv add lexigram-skills` will 404. These are markdown files (`SKILL.md`) consumed by AI coding agents, not python imports. The framework you'd `pip install` is **[lexigram](https://github.com/dbtinoy-/lexigram)** — this repo only teaches your editor how to use it.

## install

Pick the agent you use. The skills are plain markdown — any tool that reads markdown context can use them; the recipes below are the smoothest paths for the popular ones.

### OpenCode

Project-scoped — add to your `opencode.json`:

```json
{
  "plugin": ["lexigram-skills@git+https://github.com/dbtinoy-/lexigram-framework-skills.git"]
}
```

Globally — put the same `plugin` entry in `~/.config/opencode/opencode.json`. Restart the agent; skills become discoverable via the `skill` tool.

### Claude Code

Symlink (recommended — stays in sync with upstream):

```bash
git clone https://github.com/dbtinoy-/lexigram-framework-skills.git ~/.lexigram-skills
ln -s ~/.lexigram-skills ~/.claude/skills/lexigram
```

Or copy a snapshot (no auto-update; good for pinning):

```bash
git clone --depth 1 https://github.com/dbtinoy-/lexigram-framework-skills.git
cp -r lexigram-skills/*/ ~/.claude/skills/
```

Restart Claude Code; the agent will discover skills via its standard skill loader.

### Cursor

Cursor reads `*.md` files from project rules and from `~/.cursor/rules/`. Either:

```bash
git submodule add https://github.com/dbtinoy-/lexigram-framework-skills.git .cursor/rules/lexigram
```

…or copy the specific `SKILL.md` files you want into `.cursor/rules/`. Cursor surfaces them to the model as ambient context; reference them by name in your prompt to bias the model toward them.

### Continue.dev, Cline, Aider, and other markdown-aware agents

Anything that consumes a project-level instructions directory can use these skills directly:

```bash
git clone https://github.com/dbtinoy-/lexigram-framework-skills.git
# point your agent's "rules" or "instructions" path at the cloned directory,
# or symlink individual SKILL.md files into your agent's expected location.
```

### Cherry-pick a single skill

If you only need one — say `ai-subsystem-quickstart` — copy just that folder:

```bash
curl -sL https://github.com/dbtinoy-/lexigram-framework-skills/archive/main.tar.gz \
  | tar -xzf - --strip-components=1 lexigram-skills-main/ai-subsystem-quickstart
```

Drop the resulting folder into your agent's skills directory.

### Pin a version

For reproducible setups, pin to a tag or commit instead of `main`:

```bash
git clone --branch v0.1.0 --depth 1 https://github.com/dbtinoy-/lexigram-framework-skills.git
```

(Replace the tag with whatever the current release is — see [releases](https://github.com/dbtinoy-/lexigram-framework-skills/releases).)

## what's in the box

### AI

| Skill | Use when… |
|-------|-----------|
| `ai-subsystem-quickstart` | Setting up llms, rag pipelines, agents, memory, or mcp servers |

### CLI

| Skill | Use when… |
|-------|-----------|
| `cli-project-scaffolding` | Creating projects, packages, init config |
| `cli-code-generation` | Scaffolding from one of the 42 generators — models, services, controllers, more |
| `cli-database-operations` | Running migrations, seeding, backup/restore, schema inspection |
| `cli-config-and-inspect` | Viewing config, inspecting runtime, diagnosing systems |

### Core patterns

| Skill | Use when… |
|-------|-----------|
| `creating-providers-and-modules` | Wiring providers, modules, and the DI container |
| `configuration-management` | YAML config, env vars, profiles |
| `using-result-and-error-codes` | `Result[T, E]`, `LEX_ERR_*` codes, exception hierarchy |

### Data

| Skill | Use when… |
|-------|-----------|
| `database-repository-pattern` | Async SQL, repositories, domain models, migrations |
| `caching-patterns` | Multi-backend caching, stampede protection |

### Security

| Skill | Use when… |
|-------|-----------|
| `auth-and-security` | Authentication, authorization, guards, JWT, password hashing |

### Web

| Skill | Use when… |
|-------|-----------|
| `web-controllers-and-routing` | HTTP controllers, middleware, guards, CSP |
| `real-time-web` | SSE with HTMX, WebSocket, EventChannel |
| `events-and-messaging` | CQRS, event bus, queues, outbox |
| `resilience-patterns` | Retry, circuit breaker, bulkhead, rate limiting |

### UI

| Skill | Use when… |
|-------|-----------|
| `lexigram-ui` | Components, templates, CDN deps, static files |

### Testing

| Skill | Use when… |
|-------|-----------|
| `testing-with-lexigram` | `TestEnvironment`, module stubs, fakes |

## how a skill works

Each skill is a single `SKILL.md` file with YAML frontmatter (`name`, `description`) and a body of code-led examples. When you ask your AI agent to do something matching a skill's description, the agent loads that file and follows it. No magic, no plugins to write — just markdown your editor reads.

A skill is roughly: one task, twelve to a hundred lines of example code, a quick-reference table, and a short list of common mistakes. Easy to read, easy to extend.

## contributing

A new skill is a new directory with a single `SKILL.md` inside. Frontmatter:

```yaml
---
name: your-skill-name
description: Use when …
---
```

Keep the body code-led. Lead with the "what you'd write" snippet, not prose. Each skill should answer one question and end with a quick-reference table.

## repositories

- [lexigram](https://github.com/dbtinoy-/lexigram) — the framework itself
- [lexigram-docs](https://github.com/dbtinoy-/lexigram-framework-docs) — the docs site
- [lexigram-skills](https://github.com/dbtinoy-/lexigram-framework-skills) — this repo

---

*made for people who like building things and keeping them buildable.*
