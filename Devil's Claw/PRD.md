# PRD: Devil's Claw - Devil's Advocate + GitHub Scout OpenClaw Skill

## Context
Building a combined OpenClaw skill for the SURGE x OpenClaw Hackathon (deadline: March 1, 2026). The skill takes a startup/app idea via Telegram, performs competitive market analysis to tear it apart, then finds relevant GitHub repos so you can start building smarter. Target build time: ~3-4 hours using Claude, Cursor, and agentic coding tools.

---

## Product Overview

**Name:** IdeaCrusher (working title)

**One-liner:** Send your idea on Telegram. Whether it's a startup or a side project, get a reality check with real data, then armed with the GitHub repos to build it better.

**Dual Mode Detection:**
- **Startup Idea** (e.g., "I want to build a SaaS for dog walkers") -> Competitor analysis, market tear-down, pivot suggestions
- **Project/Build Idea** (e.g., "I want to build a CLI tool for managing dotfiles") -> Similar project analysis, feature comparison, differentiation suggestions

**Flow:**
```
User sends idea on Telegram
        |
        v
Step 0: Classify — Startup idea or Project/Build idea?
        |
        ├── STARTUP MODE                    ├── PROJECT MODE
        |                                   |
        v                                   v
Phase 1a: Market Analysis              Phase 1b: Similar Projects
  - Search web for competitors           - Search web for similar tools/projects
  - Identify why the idea will fail      - Compare features & gaps
  - Suggest pivots                       - Suggest differentiation angles
        |                                   |
        └───────────┬───────────────────────┘
                    |
                    v
          Phase 2: GitHub Scout
            - Find related open-source repos
            - Summarize each repo's relevance
            - Suggest tech stack / starting points
                    |
                    v
          Beautiful bulleted response on Telegram
```

---

## Functional Requirements

### Step 0: Idea Classification
- Use the LLM to classify the input as either **STARTUP** or **PROJECT**
- Keywords like "SaaS", "app for [market]", "platform", "business" -> STARTUP
- Keywords like "build a tool", "CLI", "library", "script", "bot" -> PROJECT
- If ambiguous, default to PROJECT mode (more universally useful)

### Phase 1a: Devil's Advocate Market Analysis (STARTUP mode)
- Accept a free-text idea description (e.g., "AI app for dog walkers")
- Search the web using **Tavily API** (preferred, has generous free tier) or DuckDuckGo as fallback
- Find 3-5 direct/indirect competitors
- For each competitor: name, URL, what they do, funding/traction if available
- Generate a tear-down: 3-5 reasons why the idea will fail
- Suggest 2-3 pivot directions based on market gaps

### Phase 1b: Similar Projects Analysis (PROJECT mode)
- Accept a free-text project description (e.g., "CLI tool for managing dotfiles")
- Search the web for similar existing tools/projects
- Find 3-5 similar projects
- For each: name, URL, what it does, popularity indicators
- Feature comparison: what they have vs. what you could add
- Suggest 2-3 differentiation angles (unique features, better UX, niche focus)

### Phase 2: GitHub Repo Scout
- Take the same idea + keywords extracted from Phase 1
- Search GitHub API (`GET /search/repositories`) for related repos
- Return top 5-8 repos sorted by stars/relevance
- For each repo: name, URL, stars, last updated, 2-line summary of how it's useful
- Categorize repos (e.g., "Full solutions", "Useful libraries", "Reference implementations")

### Output Format — STARTUP Mode
```
--- MARKET REALITY CHECK ---

Your idea: [restated idea]
Mode: Startup Analysis

Competitors found:
  - CompetitorA (url) — what they do, traction
  - CompetitorB (url) — what they do, traction
  - CompetitorC (url) — what they do, traction

Why this will fail:
  1. [data-backed reason]
  2. [data-backed reason]
  3. [data-backed reason]

Pivot suggestions:
  - [pivot 1 — based on market gap]
  - [pivot 2 — based on market gap]

--- GITHUB ARSENAL ---

Ready-to-use repos:
  - repo-name (stars) — summary
  - repo-name (stars) — summary

Useful libraries:
  - repo-name (stars) — summary

Start here: [recommended repo + why]
```

### Output Format — PROJECT Mode
```
--- PROJECT REALITY CHECK ---

Your idea: [restated idea]
Mode: Project Analysis

Similar projects found:
  - ProjectA (url) — what it does, popularity
  - ProjectB (url) — what it does, popularity
  - ProjectC (url) — what it does, popularity

Feature comparison:
  | Feature        | ProjectA | ProjectB | Yours (opportunity) |
  |----------------|----------|----------|---------------------|
  | Feature X      | Yes      | No       | Build this          |
  | Feature Y      | No       | Yes      | Improve on this     |

How to differentiate:
  1. [angle 1]
  2. [angle 2]

--- GITHUB ARSENAL ---

Similar implementations:
  - repo-name (stars) — summary
  - repo-name (stars) — summary

Useful libraries:
  - repo-name (stars) — summary

Start here: [recommended repo + why]
```

---

## Technical Architecture

### Setup (Main Linux Laptop - Docker Sandbox)

```
~/clawd/
  ├── SOUL.md                    # Devil's Advocate persona
  ├── skills/
  │   └── idea-crusher/
  │       ├── SKILL.md           # Skill definition + instructions
  │       └── tools/
  │           ├── market_search.py    # Tavily API integration
  │           ├── github_scout.py     # GitHub API integration
  │           └── pyproject.toml      # uv-managed dependencies
```

### Key Files to Create

#### 1. `SOUL.md` - Devil's Advocate Persona
- Personality: Brutally honest startup advisor, data-driven, constructive
- Rules: Always back claims with search data, always end with actionable pivots
- Tone: Direct, no sugar-coating, but ultimately helpful

#### 2. `skills/idea-crusher/SKILL.md` - Skill Definition
```yaml
---
name: idea-crusher
version: 1.0.0
description: Tears apart your startup idea with market data, then arms you with GitHub repos
requires:
  - tavily-api-key
  - github-token
---
```
- Step-by-step instructions for the agent:
  1. Extract keywords from the idea
  2. Call market_search tool with keywords
  3. Analyze results and generate tear-down
  4. Call github_scout tool with refined keywords
  5. Format and return combined response

#### 3. `tools/market_search.py` - Tavily Web Search
- Uses Tavily Search API (`POST https://api.tavily.com/search`)
- Free tier: 1,000 searches/month (more than enough)
- Dependencies: `httpx` (managed via uv)
- Input: search query string
- Output: list of {title, url, snippet, relevance_score}

#### 4. `tools/github_scout.py` - GitHub Repo Search
- Uses GitHub REST API (`GET https://api.github.com/search/repositories`)
- No auth needed for basic search (60 req/hr), or use token for 5,000 req/hr
- Dependencies: `httpx` (managed via uv)
- Input: search query, sort by stars
- Output: list of {name, url, description, stars, updated_at, language}

#### 5. `tools/pyproject.toml` - uv Package Management
```toml
[project]
name = "idea-crusher-tools"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "httpx>=0.27",
    "tavily-python>=0.5",
]
```
- Use `uv sync` to install dependencies
- Use `uv run` to execute tool scripts

### API Keys Required
| Service | Free Tier | Signup |
|---------|-----------|--------|
| Tavily | 1,000 searches/mo | https://tavily.com |
| GitHub | 60 req/hr (unauthenticated) | Optional token for higher limits |
| LLM (Claude/OpenAI) | Via OpenClaw config | Already configured in OpenClaw |

### Environment Setup (Linux + Docker)
```bash
# 1. Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. Clone OpenClaw
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# 3. Run onboarding
./openclaw onboard
# -> Select Telegram channel (requires Telegram Bot Token from @BotFather)
# -> Configure LLM provider (Claude API recommended)

# 4. Start with Docker Compose
docker compose up -d

# 5. Copy skill files & install Python deps
cp -r idea-crusher/ ~/clawd/skills/
cd ~/clawd/skills/idea-crusher/tools
uv sync

# 6. Set API keys in .env
TAVILY_API_KEY=your_key_here
GITHUB_TOKEN=your_token_here  # optional
```

### Telegram Bot Setup
- Create bot via @BotFather on Telegram -> get bot token
- Add token to OpenClaw channel config during onboarding
- Bot will be accessible to anyone who messages it (or restrict via config)

### Windows Laptops (Secondary)
- Can connect to the same OpenClaw instance via Telegram (it's channel-based)
- No local setup needed on Windows - just message the Telegram bot
- For development: use WSL2 or connect to the Linux machine remotely

---

## 3-Hour Build Plan

| Time | Task | Who/What |
|------|------|----------|
| 0:00-0:30 | OpenClaw Docker setup + Telegram channel config | Linux laptop, terminal |
| 0:30-1:00 | Write SOUL.md + SKILL.md (prompt engineering) | Claude/Cursor |
| 1:00-1:30 | Build market_search.py (Tavily integration) | Claude/Cursor |
| 1:30-2:00 | Build github_scout.py (GitHub API integration) | Claude/Cursor |
| 2:00-2:30 | Integration testing via Telegram, fix formatting | All laptops |
| 2:30-3:00 | Polish output format, edge cases, demo prep | All laptops |

---

## Why This Wins the Hackathon

1. **Instantly demo-able** - Judge sends an idea on Telegram, gets roasted in 30 seconds
2. **Uses OpenClaw's strengths** - SOUL.md persona, custom skills, Telegram channel, memory
3. **Actually useful** - Every builder at the hackathon has an idea they haven't validated
4. **Technically sound** - Real API integrations, not just prompt tricks
5. **Privacy-first** - Self-hosted, data stays local (aligns with OpenClaw philosophy)

---

## Verification / Demo Script

**Startup mode test:**
1. Send on Telegram: "I want to build an AI app for dog walkers"
2. Verify: Response includes real competitors (e.g., Rover, Wag, Barkly)
3. Verify: Tear-down has specific, data-backed reasons
4. Verify: GitHub repos are real, relevant, and properly summarized

**Project mode test:**
5. Send on Telegram: "I want to build a CLI tool that manages dotfiles across machines"
6. Verify: Response shows similar projects (e.g., chezmoi, stow, yadm)
7. Verify: Feature comparison table is present
8. Verify: Differentiation suggestions are actionable

**General:**
9. Verify: Response is well-formatted with clear sections
10. Test edge cases: vague ideas, ambiguous (startup vs project), very niche ideas
