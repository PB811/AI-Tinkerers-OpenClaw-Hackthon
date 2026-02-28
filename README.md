# Devil's Claw

> Send your idea on Telegram. Get a brutal reality check with real data, then get the GitHub repos to build it smarter.

Built for the **SURGE x OpenClaw Hackathon** (March 2026).

---

## What It Does

Devil's Claw is an OpenClaw skill that acts as a brutally honest startup and project advisor via Telegram.

**Dual mode detection:**
- **STARTUP mode** — finds real competitors, tears apart why it'll fail, suggests pivots
- **PROJECT mode** — finds similar tools, builds a feature comparison, suggests differentiation angles

Both modes end with a **GitHub Arsenal** — real repos ranked by relevance to help you start building.

## Demo

Send any idea to the Telegram bot and get back a structured reality check in ~30 seconds:

```
"I want to build an AI app for dog walkers"
→ STARTUP mode: Rover, Wag!, market data, 3 pivot options, GitHub repos

"I want to build a CLI tool for managing dotfiles"
→ PROJECT mode: chezmoi, stow, yadm comparison, differentiation angles, GitHub repos
```

---

## Stack

| Component | Technology |
|---|---|
| Framework | OpenClaw |
| LLM | Claude Sonnet 4.5 via OpenRouter |
| Web search | Perplexity Sonar (built-in OpenClaw tool) |
| Channel | Telegram |
| Infra | Docker Compose |

---

## Setup

### Prerequisites
- Docker + Docker Compose
- Node.js 22+
- A Telegram bot token (from [@BotFather](https://t.me/BotFather))
- An [OpenRouter](https://openrouter.ai) API key

### 1. Install OpenClaw

```bash
git clone https://github.com/openclaw/openclaw.git ~/openclaw
cd ~/openclaw
./docker-setup.sh
```

Follow the onboarding wizard. When it asks for the LLM provider, select **OpenRouter** and paste your API key.

### 2. Configure

Edit `~/.openclaw/openclaw.json`:

```json
{
  "gateway": {
    "mode": "local",
    "auth": { "token": "<your-gateway-token>" }
  },
  "env": {
    "OPENROUTER_API_KEY": "<your-openrouter-key>"
  },
  "agents": {
    "defaults": {
      "model": { "primary": "openrouter/anthropic/claude-sonnet-4-5" }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "<your-telegram-bot-token>",
      "dmPolicy": "open",
      "allowFrom": ["*"]
    }
  }
}
```

### 3. Deploy the Skill

```bash
# Copy skill files to OpenClaw workspace
mkdir -p ~/.openclaw/workspace/skills/devils-claw/tools

cp "Devil's Claw/SOUL.md" ~/.openclaw/workspace/
cp "Devil's Claw/SKILL.md" ~/.openclaw/workspace/skills/devils-claw/
cp "Devil's Claw/tools/"* ~/.openclaw/workspace/skills/devils-claw/tools/

# Start the gateway
docker compose -f ~/openclaw/docker-compose.yml up -d openclaw-gateway
```

### 4. Test It

DM your Telegram bot:
```
I want to build a SaaS for restaurant reservations
```

---

## Project Structure

```
Devil's Claw/
  ├── SOUL.md          # Devil's Advocate persona
  ├── SKILL.md         # Step-by-step agent instructions
  ├── PRD.md           # Full product requirements
  └── tools/
      ├── market_search.py   # Tavily web search tool (reference)
      ├── github_scout.py    # GitHub API search tool (reference)
      └── pyproject.toml     # Python dependencies
```

---

## Why Devil's Claw Wins

1. **Instantly demo-able** — judge sends an idea, gets roasted in 30 seconds
2. **Actually useful** — every builder has an unvalidated idea
3. **Real data** — no hallucinations, all claims backed by live web search
4. **OpenClaw native** — SOUL.md persona, custom skill, Telegram channel
