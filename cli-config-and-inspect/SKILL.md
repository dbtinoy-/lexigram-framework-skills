---
name: cli-config-and-inspect
description: Use when viewing or validating configuration, inspecting runtime state, diagnosing system issues, or managing CLI contributors in Lexigram
---

# CLI Config and Inspect

## Overview

`lexigram config` manages application configuration. `lexigram inspect` exposes runtime state. `lexigram system` diagnoses the environment. `lexigram contrib` discovers CLI extensions.

## Configuration

```bash
lexigram config show                        # Resolved config (secrets masked)
lexigram config show --reveal-secrets       # Unmasked
lexigram config validate                    # Schema + cross-field validation
lexigram config doctor --env production     # Environment-specific diagnostics
lexigram config env                         # Show ${VAR} references and status
lexigram config env --missing               # Exit 1 if any unset
lexigram config env-example                 # Generate .env.example
lexigram config diff -c other.yaml          # Compare two config files
lexigram config schema                      # Dump JSON schema
```

## Runtime Inspection

```bash
lexigram inspect providers                  # Registered providers + priority
lexigram inspect routes                     # All HTTP + GraphQL routes
lexigram inspect middleware                 # Middleware stack order
lexigram inspect container                  # DI container registrations
lexigram inspect events                     # Registered event handlers
lexigram inspect tasks                      # Registered task handlers
lexigram inspect dependencies              # Provider dependency graph
lexigram inspect modules                   # All registered modules
lexigram inspect health                     # Provider health status
```

## System Diagnostics

```bash
lexigram system info                        # Python, platform, config path
lexigram system health                      # Project + contributor health
lexigram system doctor --fix               # Diagnostics with auto-fix
lexigram system providers                   # Provider sections in YAML
lexigram system shell                       # Interactive Lexigram REPL
```

## Contributors

```bash
lexigram contrib list                       # All contributors + their surface
lexigram contrib inspect sql               # Details for one contributor
lexigram contrib check                      # Verify all load without errors
```

## Global Flags

| Flag | Effect |
|------|--------|
| `--json` | Machine-readable output |
| `-q / --quiet` | Suppress non-essential output |
| `--debug` | Print tracebacks |
| `--no-color` | Disable ANSI |
| `-c / --config` | Path to `application.yaml` |

## Common Mistakes

- Inspecting routes before starting the app — `lexigram inspect` needs a running or configured app
- Using `config show --reveal-secrets` in CI logs — secrets leak
- Running `config validate` with missing env vars — config may be valid but incomplete
- Not using `--json` for programmatic consumption — human-friendly output is fragile to parse
