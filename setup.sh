#!/usr/bin/env bash
set -euo pipefail

# Devil's Claw — one-command setup
# Usage: ./setup.sh

echo "==> Checking .env file..."
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example — fill in your API keys and re-run."
  exit 1
fi

source .env

if [ -z "${OPENROUTER_API_KEY:-}" ] || [ "${OPENROUTER_API_KEY}" = "sk-or-v1-..." ]; then
  echo "ERROR: Set OPENROUTER_API_KEY in .env first."
  exit 1
fi

if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ "${TELEGRAM_BOT_TOKEN}" = "123456:ABC-..." ]; then
  echo "ERROR: Set TELEGRAM_BOT_TOKEN in .env first."
  exit 1
fi

# Generate gateway token if not set
if [ -z "${OPENCLAW_GATEWAY_TOKEN:-}" ] || [ "${OPENCLAW_GATEWAY_TOKEN}" = "your_gateway_token_here" ]; then
  TOKEN=$(openssl rand -hex 32)
  sed -i "s|OPENCLAW_GATEWAY_TOKEN=.*|OPENCLAW_GATEWAY_TOKEN=$TOKEN|" .env
  source .env
  echo "Generated gateway token."
fi

echo "==> Writing openclaw config..."
mkdir -p openclaw_config_tmp

cat > openclaw_config_tmp/openclaw.json << EOF
{
  "gateway": {
    "mode": "local",
    "auth": { "token": "${OPENCLAW_GATEWAY_TOKEN}" },
    "controlUi": { "allowedOrigins": ["http://127.0.0.1:18789"] }
  },
  "env": {
    "OPENROUTER_API_KEY": "${OPENROUTER_API_KEY}"
  },
  "agents": {
    "defaults": {
      "model": { "primary": "openrouter/anthropic/claude-sonnet-4-5" }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "dmPolicy": "open",
      "allowFrom": ["*"]
    }
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true
  }
}
EOF

# Copy config into the Docker volume
docker run --rm \
  -v "$(pwd)/openclaw_config_tmp:/src" \
  -v "$(pwd)_openclaw_config:/home/node/.openclaw" \
  --entrypoint sh \
  ghcr.io/openclaw/openclaw:latest \
  -c "cp /src/openclaw.json /home/node/.openclaw/openclaw.json" 2>/dev/null || true

rm -rf openclaw_config_tmp

echo "==> Pulling latest OpenClaw image..."
docker pull ghcr.io/openclaw/openclaw:latest

echo "==> Starting Devil's Claw..."
docker compose up -d openclaw-gateway

echo ""
echo "✅ Devil's Claw is running!"
echo ""
echo "Telegram: DM your bot an idea to test it"
echo "Logs:     docker compose logs -f openclaw-gateway"
echo "Stop:     docker compose down"
echo ""
echo "Gateway token: ${OPENCLAW_GATEWAY_TOKEN}"
