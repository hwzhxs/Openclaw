# Personal Knowledge Base (RAG) — Absorbed from awesome-openclaw-usecases

## What It Is
Drop URLs (articles, tweets, YouTube, PDFs) into a channel → auto-ingest into searchable knowledge base with semantic search.

## How It Works
- Ingest: drop URL → fetch content → chunk + embed → store with metadata (title, URL, date, type)
- Query: ask natural language questions → semantic search → ranked results with sources
- Cross-workflow: other tasks can query the KB automatically (e.g., research for video ideas)

## Setup
1. Install `knowledge-base` skill from ClawHub
2. Create dedicated channel/topic for ingestion
3. Configure agent to auto-ingest URLs dropped in that channel
4. Query with natural language

## For Our Team
- Overlaps significantly with Semantic Memory Search (memsearch)
- Key difference: this ingests EXTERNAL content (URLs, articles), memsearch indexes INTERNAL memory files
- Could complement each other: memsearch for our decisions/context, RAG KB for external research
- Requires ClawHub skill — need to check if `knowledge-base` is actually published there

## Assessment
- Medium priority for me — memsearch solves the more urgent pain point (finding our own past work)
- This becomes valuable once we have enough external research to warrant a persistent knowledge store
