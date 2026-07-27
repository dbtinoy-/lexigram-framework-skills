---
name: ai-subsystem-quickstart
description: Use when setting up the AI subsystem — LLM clients, RAG pipelines, agents, memory, or MCP servers in the Lexigram framework
---

# AI Subsystem Quickstart

## Overview

Lexigram's AI stack is modular: 15+ `lexigram-ai-*` packages wired through `AIModule`. All follow contract-first DI — inject `*Protocol`, swap backends via config. See `docs/lexigram-docs/guides/ai-*.md` for deep dives.

## LLM Client

```python
from lexigram.contracts.ai.llm import LLMClientProtocol
from lexigram.contracts.ai.llm import ChatMessage, Role

class MyService:
    def __init__(self, llm: LLMClientProtocol):
        self.llm = llm

    async def summarize(self, text: str) -> Result[str, AIError]:
        messages = [ChatMessage(role=Role.USER, content=text)]
        result = await self.llm.complete(messages)
        return result.map_sync(lambda r: r.content)
```

## RAG Pipeline

```python
from lexigram.contracts.ai.rag import RAGPipelineProtocol

class QAService:
    def __init__(self, rag: RAGPipelineProtocol):
        self.rag = rag

    async def answer(self, question: str) -> Result[str, AIError]:
        result = await self.rag.query(question)
        return result.map_sync(lambda r: r.answer)
```

## Agents

```python
from lexigram.contracts.agents import AgentExecutorProtocol, ToolProtocol

class SearchTool(ToolProtocol):
    async def execute(self, query: str) -> str:
        return f"Results for: {query}"

agent = await container.resolve(AgentExecutorProtocol)
result = await agent.execute("Find docs about caching")
```

## Configuration

Hosted (OpenAI, Anthropic, …):

```yaml
ai_llm:
  provider: openai
  model: gpt-4-turbo
  api_key: ${OPENAI_API_KEY}
  temperature: 0.7
  max_tokens: 2048
  thinking:                       # For reasoning models
    budget_tokens: 4096
```

Local — any OpenAI-compatible server (Ollama, LM Studio, vLLM, llama.cpp):

```yaml
ai_llm:
  provider: openai_compatible
  model: llama3.2
  api_base: http://localhost:11434/v1   # Ollama default; swap for LM Studio / vLLM
  api_key: ollama                       # Local servers usually ignore the value
  temperature: 0.7
  max_tokens: 2048
```

## Module Registration

```python
from lexigram.ai import AIModule
from lexigram.ai.llm import LLMModule

async with Application.boot(modules=[
    AIModule.configure(ai_config),
    LLMModule.configure(llm_config),
]) as app:
    llm = await app.container.resolve(LLMClientProtocol)
```

## Testing

```python
@module(imports=[LLMModule.stub()])  # No-op LLM
class TestModule(Module): pass
```

## Quick Reference

| Package | Protocol | Purpose |
|---------|----------|---------|
| `lexigram-ai-llm` | `LLMClientProtocol` | Multi-provider LLM (OpenAI, Anthropic, Ollama...) |
| `lexigram-ai-rag` | `RAGPipelineProtocol` | Document retrieval + synthesis |
| `lexigram-ai-agents` | `AgentExecutorProtocol` | ReAct, plan-and-execute agents with tools |
| `lexigram-ai-memory` | `MemoryStoreProtocol` | Working, episodic, semantic memory |
| `lexigram-ai-mcp` | — | MCP server/client for external tools |
| `lexigram-ai-guard` | `GuardPipelineProtocol` | Input/output safety guards |
| `lexigram-ai-governance` | — | Cost tracking, budgets, rate limits |
| `lexigram-ai-prompt` | `PromptTemplateProtocol` | Prompt templates and management |
| `lexigram-ai-skills` | `SkillProtocol` | Skill/tool registry and execution |
| `lexigram-ai-session` | `SessionManagerProtocol` | Conversation session management |

## Common Mistakes

- Importing across AI sub-packages — use contracts + DI, never `lexigram-ai-agents` → `lexigram-ai-llm`
- Forgetting `ThinkingConfig` for reasoning models — default suppresses thinking tokens
- Not calling `result.map()` on LLM responses — forget Result unwrapping discipline
- Missing LLM `fallback` providers — single-provider setup has no resilience
- Using `LLMModule.stub()` when testing — otherwise tests call real APIs
