# lexigram-skills — Makefile
# Manages skill files for AI coding agents (Claude Code, OpenCode, …)
# that teach the agent how to build with the Lexigram framework.
# Publish workflow mirrors lexigram-docs/Makefile.

LEXIGRAM_DIR ?= ../lexigram
DOCS_SRC     ?= ../lexigram-docs/src/content/docs
PYTHON       := python3
SKILLS       := $(wildcard */SKILL.md)

.DEFAULT_GOAL := help

.PHONY: help
help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

.PHONY: prepare
prepare:  ## Validate, cross-reference docs + REF files
	$(PYTHON) scripts/prepare-skills.py --docs $(DOCS_SRC) --refs

.PHONY: publish
publish: prepare  ## Validate, commit, push. Usage: make publish m="commit message"
	@if [ -z "$(m)" ]; then echo "ERROR: m=\"commit message\" is required"; exit 1; fi
	@# Stage only the things this repo tracks. Never -A (would sweep up unrelated
	@# dirty files), and never scripts/ (that directory is gitignored — see .gitignore).
	git add README.md Makefile .opencode/INSTALL.md */SKILL.md
	@if git diff --cached --quiet; then \
	  echo "Nothing to publish — no tracked files changed."; \
	  exit 0; \
	fi
	git commit -m "$(m)"
	git push

.PHONY: validate
validate:  ## Validate all skill frontmatter (shell, fast)
	@echo "=== Validating skills ==="
	@errors=0; \
	for f in $(SKILLS); do \
	  name=$$(dirname $$f); \
	  content=$$(cat $$f); \
	  fm=$$(echo "$$content" | sed -n '/^---$$/,/^---$$/p' | head -n -1 | tail -n +2); \
	  if [ -z "$$fm" ]; then echo "  ✗ $$name: MISSING frontmatter"; errors=$$((errors+1)); continue; fi; \
	  n=$$(echo "$$fm" | grep -E '^name:\s+' | head -1); \
	  d=$$(echo "$$fm" | grep -E '^description:\s+' | head -1); \
	  if [ -z "$$n" ]; then echo "  ✗ $$name: MISSING name"; errors=$$((errors+1)); \
	  else echo "  ✓ $$name"; fi; \
	  if [ -z "$$d" ]; then echo "  ✗ $$name: MISSING description"; errors=$$((errors+1)); fi; \
	  if echo "$$d" | grep -qv 'Use when'; then echo "  ⚠ $$name: description should start with 'Use when'"; fi; \
	done; \
	echo ""; \
	if [ $$errors -eq 0 ]; then echo "All skills valid."; else echo "$$errors error(s)."; exit 1; fi

.PHONY: stats
stats:  ## Show word counts per skill
	@printf "%-40s %6s\n" "Skill" "Words"
	@printf "%-40s %6s\n" "----------------------------------------" "------"
	@total=0; \
	for f in $(SKILLS); do \
	  wc=$$(sed '1,/^---$$/d' $$f | wc -w); \
	  printf "%-40s %6d\n" $$(dirname $$f) $$wc; \
	  total=$$((total+wc)); \
	done; \
	printf "%-40s %6d\n" "" "------"; \
	printf "%-40s %6d\n" "TOTAL" $$total

.PHONY: check
check: prepare  ## Run full prep (alias for prepare)

.PHONY: lint
lint:  ## Quick lint checks (name conventions, word counts)
	@echo "=== Lint checks ==="
	@errors=0; \
	for f in $(SKILLS); do \
	  name=$$(dirname $$f); \
	  if echo "$$name" | grep -qE '[^a-z0-9-]'; then \
	    echo "  ✗ $$name: name contains invalid chars (lowercase + hyphens only)"; \
	    errors=$$((errors+1)); \
	  fi; \
	  wc=$$(sed '1,/^---$$/d' $$f | wc -w); \
	  if [ $$wc -gt 500 ]; then \
	    echo "  ⚠ $$name: $$wc words (recommend <500)"; \
	  fi; \
	done; \
	[ $$errors -eq 0 ] && echo "All lint checks passed." || (echo "$$errors lint error(s)."; exit 1)

.PHONY: new
new:  ## Scaffold a new skill: make new SKILL=my-skill-name
	@if [ -z "$(SKILL)" ]; then echo "Usage: make new SKILL=my-skill-name"; exit 1; fi; \
	dir="$(SKILL)"; \
	if [ -d "$$dir" ]; then echo "Skill $$dir already exists."; exit 1; fi; \
	mkdir -p "$$dir"; \
	cat > "$$dir/SKILL.md" <<- EOF
	---
	name: $(SKILL)
	description: Use when [describe triggering conditions — NOT what the skill does]
	---
	
	# $(SKILL)
	
	## Overview
	
	Core principle in 1-2 sentences.
	
	## When to Use
	
	- Symptom 1
	- Symptom 2
	
	## Core Pattern
	
	\`\`\`python
	# Example code
	\`\`\`
	
	## Common Mistakes
	
	- Mistake 1
	- Mistake 2
	EOF
	@echo "Created skill: $$dir/SKILL.md"

.PHONY: from-docs
from-docs:  ## Show doc-to-skill mapping from lexigram-docs
	@echo "=== Documentation sources for skills ==="
	@for skill in ai-subsystem-quickstart caching-patterns cli-code-generation cli-config-and-inspect cli-database-operations cli-project-scaffolding configuration-management creating-providers-and-modules database-repository-pattern events-and-messaging resilience-patterns testing-with-lexigram using-result-and-error-codes web-controllers-and-routing; do \
	  echo ""; \
	  echo "--- $$skill ---"; \
	  case "$$skill" in \
	    ai-subsystem-quickstart)         echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/ai-integration.md $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/ai-llm.md $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/ai-agents.md $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/ai-rag.md 2>/dev/null;; \
	    caching-patterns)                echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/caching.md 2>/dev/null;; \
	    configuration-management)        echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/fundamentals/yaml-configuration.md $(LEXIGRAM_DIR)/docs/lexigram-docs/fundamentals/configuration.md 2>/dev/null;; \
	    creating-providers-and-modules)  echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/fundamentals/providers.md $(LEXIGRAM_DIR)/docs/lexigram-docs/fundamentals/modules.md $(LEXIGRAM_DIR)/docs/lexigram-docs/fundamentals/dependency-injection.md $(LEXIGRAM_DIR)/docs/lexigram-docs/fundamentals/container-protocols.md $(LEXIGRAM_DIR)/docs/lexigram-docs/fundamentals/boot-lifecycle.md 2>/dev/null;; \
	    database-repository-pattern)     echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/database.md 2>/dev/null;; \
	    events-and-messaging)            echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/event-driven.md $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/queue.md 2>/dev/null;; \
	    resilience-patterns)             echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/resilience.md 2>/dev/null;; \
	    testing-with-lexigram)           echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/testing.md 2>/dev/null;; \
	    cli-project-scaffolding)         echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/cli.md 2>/dev/null;; \
	    cli-code-generation)             echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/reference/REF_CLI_COMMANDS.md 2>/dev/null;; \
	    cli-database-operations)         echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/database.md $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/cli.md 2>/dev/null;; \
	    cli-config-and-inspect)          echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/fundamentals/yaml-configuration.md $(LEXIGRAM_DIR)/docs/lexigram-docs/guides/cli.md 2>/dev/null;; \
	    using-result-and-error-codes)    echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/fundamentals/result-pattern.md $(LEXIGRAM_DIR)/docs/lexigram-docs/reference/REF_ERROR_CODES.md 2>/dev/null;; \
	    web-controllers-and-routing)     echo "  sources:"; ls $(LEXIGRAM_DIR)/docs/lexigram-docs/fundamentals/architecture.md 2>/dev/null;; \
	  esac; \
	done
