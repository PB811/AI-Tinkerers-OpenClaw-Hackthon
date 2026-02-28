# IdeaCrusher - Project Instructions

## Overview
IdeaCrusher is an OpenClaw skill for the SURGE x OpenClaw Hackathon (deadline: March 1, 2026). It's a Telegram bot that takes startup/project ideas, tears them apart with real market data, and finds relevant GitHub repos.

## Project Structure
```
~/clawd/
  ├── SOUL.md                         # Devil's Advocate persona
  ├── skills/
  │   └── idea-crusher/
  │       ├── SKILL.md                # Skill definition + instructions
  │       └── tools/
  │           ├── market_search.py    # Tavily API integration
  │           ├── github_scout.py     # GitHub API integration
  │           └── pyproject.toml      # uv-managed dependencies
```

## Key Design Decisions
- **Dual mode**: Classify input as STARTUP or PROJECT, default to PROJECT if ambiguous
- **Tavily API** for web search (free tier: 1,000 searches/mo)
- **GitHub REST API** for repo search (unauthenticated: 60 req/hr, with token: 5,000 req/hr)
- **httpx** as the HTTP client (async-capable, modern)
- **uv** for Python package management
- **Docker Compose** for deployment via OpenClaw

## Tech Stack
- Python 3.11+
- httpx for HTTP requests
- tavily-python SDK
- uv for dependency management
- OpenClaw framework (SOUL.md + SKILL.md + tools pattern)
- Telegram as the user-facing channel

## API Integrations
1. **Tavily Search API** (`POST https://api.tavily.com/search`) - web search for competitors/similar projects
2. **GitHub Search API** (`GET https://api.github.com/search/repositories`) - find related repos

## Environment Variables
- `TAVILY_API_KEY` - Required for web search
- `GITHUB_TOKEN` - Optional, for higher GitHub API rate limits

## Coding Conventions
- Tools are standalone Python scripts in `tools/`
- Each tool reads from stdin (JSON) and writes to stdout (JSON)
- Follow OpenClaw tool conventions for input/output format
- Keep tools simple and focused — one responsibility per file
- Use type hints throughout
- Handle API errors gracefully with meaningful error messages

## Build Order
1. SOUL.md (persona definition)
2. SKILL.md (skill definition with step-by-step agent instructions)
3. market_search.py (Tavily integration)
4. github_scout.py (GitHub API integration)
5. pyproject.toml (dependencies)
6. Integration testing via Telegram

## PRD Reference
See `PRD.md` in this directory for full product requirements, output formats, and verification steps.
