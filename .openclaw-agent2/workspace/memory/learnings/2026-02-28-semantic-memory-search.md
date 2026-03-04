# Semantic Memory Search — Absorbed from awesome-openclaw-usecases

## What It Is
Vector-powered semantic search over OpenClaw markdown memory files using [memsearch](https://github.com/zilliztech/memsearch) (by Zilliz/Milvus team).

## How It Works
- Indexes markdown memory files into Milvus vector DB
- Hybrid search: dense vectors (semantic) + BM25 (keyword) with RRF reranking
- SHA-256 content hashing = only re-embeds changed content (saves API costs)
- File watcher auto-reindexes on changes
- Works fully local (no API key) or with OpenAI/Google/Voyage/Ollama embeddings

## Setup (5 minutes)
```bash
pip install memsearch
memsearch config init          # interactive wizard
memsearch index ~/memory/      # index memory files
memsearch search "what caching solution did we pick?"
memsearch watch ~/memory/      # live auto-reindex
```

For fully local (no API):
```bash
pip install "memsearch[local]"
memsearch config set embedding.provider local
```

## Key Insights
- Markdown stays source of truth — vector index is derived cache, rebuildable anytime
- Hybrid search > pure vector search (catches both meaning + exact matches)
- Smart dedup via content hash = safe to re-run index repeatedly

## For Our Team
- Every agent would benefit — search across all memory/ files by meaning
- Could run `memsearch watch` as a background service
- Query from agents via CLI: `memsearch search "query"` in exec calls
- No OpenClaw skill needed — standalone Python CLI

## Links
- https://github.com/zilliztech/memsearch
- https://zilliztech.github.io/memsearch/
