---
name: cli-project-scaffolding
description: Use when creating a new Lexigram project, scaffolding an extension package, or setting up configuration in an existing project
---

# CLI Project Scaffolding

## Overview

The `lexigram new` and `lexigram init` commands create project skeletons. `lexigram add` installs and configures extension packages.

## Creating a Project

```bash
lexigram new project my-app                  # web-api template (default)
lexigram new project my-app --template api   # JSON API only
lexigram new project my-app --template full  # web + db + auth + cache
lexigram new project my-app --interactive    # prompts for template/DB/auth
```

## Scaffolding an Extension

```bash
lexigram new package my-feature              # → lexigram-my-feature/
```

Generates the full package structure: `src/lexigram/my_feature/` with `config.py`, `module.py`, `exceptions.py`, `di/provider.py`, `pyproject.toml`.

## Adopting Lexigram in Existing Projects

```bash
lexigram init                                # minimal application.yaml
lexigram init --full                         # all sections (web, db, auth, cache...)
lexigram init --force                        # overwrite existing config
```

## Adding Packages

```bash
lexigram add database                        # uv add lexigram-sql + db: config block
lexigram add auth                            # uv add lexigram-auth + auth: config block
```

The `add` command edits `pyproject.toml` and patches `application.yaml` with the provider's default configuration.

## Quick Reference

| Command | Use Case |
|---------|----------|
| `new project <name>` | Full app from template |
| `new package <name>` | Reusable extension |
| `init` | Config into existing dir |
| `add <package>` | Install + configure |

## Common Mistakes

- Running `new project` inside an existing project — use a fresh directory
- Forgetting `--interactive` — default template has no DB or auth
- Running `init` after `new project` redundant — `new` already generates config
