# Absorbed: Semantic Memory Search

**Source:** https://github.com/hesamsheikh/awesome-openclaw-usecases/blob/main/usecases/semantic-memory-search.md
**Absorbed:** 2026-02-28

## What It Solves
Markdown memory files have no search — only grep (keyword-only) or loading whole files (wastes tokens). This adds vector-powered semantic search via `memsearch`.

## Tool: memsearch
- GitHub: https://github.com/zilliztech/memsearch
- Docs: https://zilliztech.github.io/memsearch/
- Backend: Milvus vector database
- Python 3.10+ required

## Setup
```bash
pip install memsearch
memsearch config init          # interactive config wizard
memsearch index ~/memory/      # index memory directory
memsearch search "query"       # search by meaning
memsearch watch ~/memory/      # auto-reindex on file change
```

### Fully Local (no API keys)
```bash
pip install "memsearch[local]"
memsearch config set embedding.provider local
memsearch index ~/memory/
```

## Key Design Points
- **Markdown stays source of truth** — vector index is derived cache, rebuildable anytime
- **SHA-256 content hashing** — only new/changed content gets re-embedded (no wasted API calls)
- **Hybrid search** — dense vectors + BM25 full-text with RRF reranking
- **Supports:** OpenAI, Google, Voyage, Ollama, or fully local embeddings

## Gatekeeper Review Notes
- ✅ Non-invasive — never modifies source markdown files
- ✅ Smart dedup via content hashing — cost-efficient
- ✅ Local option available — no credential exposure needed
- ⚠️ Requires Python 3.10+ and Milvus — adds infra dependency
- ⚠️ Need to verify memsearch repo security before installing
- 📋 TODO: Review memsearch source code before team-wide deployment
