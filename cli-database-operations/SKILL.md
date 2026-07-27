---
name: cli-database-operations
description: Use when running database migrations, seeding data, backing up, or inspecting the database schema in a Lexigram project
---

# CLI Database Operations

## Overview

`lexigram db` manages the full database lifecycle — migrations, seeding, backup/restore, inspection, and shell access — via `lexigram-sql`'s migration runner.

## Migration Lifecycle

```bash
lexigram db init migrations                 # Create migrations/ directory
lexigram db create add_users_table          # New empty migration file
lexigram db upgrade                         # Apply pending migrations
lexigram db downgrade                       # Roll back the most recent
lexigram db downgrade 0003_seed             # Roll back to a specific version
lexigram db status                          # Current version + pending
lexigram db history --limit 20              # Last N applied migrations
lexigram db validate                        # Check applied migrations have files
```

## Seeding

```bash
lexigram db seed                            # Run all seed scripts
lexigram db reset --seed                    # Drop + recreate + seed
```

Seed scripts live in `seeds/*.py`, each exposing `async def run(provider)`.

## Inspection & Administration

```bash
lexigram db inspect                         # List tables + columns
lexigram db inspect --table users           # One table's columns + types
lexigram db shell                           # Open psql/mysql/sqlite3 client
lexigram db reset --force                   # Drop + re-migrate (SQLite-optimized)
```

## Backup & Restore

```bash
lexigram db backup --output dump.sql
lexigram db restore dump.sql --force
```

## Config

```yaml
db:
  url: postgresql+asyncpg://user:pass@localhost:5432/mydb
  pool_size: 10
```

Default is `sqlite:///./dev.db`. All db commands read `DATABASE_URL` from env.

## Common Mistakes

- Running `upgrade` before `init` — migrations directory must exist
- Running `downgrade` without specifying target — reverts only the most recent
- Editing applied migration files — write a new migration instead
- `reset --force` without backup — irreversible data loss
- Using sync driver (psycopg2) in async context — use `+asyncpg` URL
