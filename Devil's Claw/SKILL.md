# Skill: Devil's Claw

## Trigger
Activate when the user sends any startup idea, app idea, project idea, or asks "what do you think of my idea".

## Step 0: Classify the Idea
Classify the input as either **STARTUP** or **PROJECT**:
- **STARTUP**: mentions SaaS, app for a market, platform, business, monetization, users → STARTUP
- **PROJECT**: mentions building a tool, CLI, library, script, bot, open-source thing → PROJECT
- If ambiguous → default to **PROJECT**

State the classification briefly before proceeding.

## Step 1a: Market Analysis (STARTUP mode)
1. Extract 2-3 keywords from the idea
2. Use web_search: `"[keywords] competitors market 2025"`
3. Use web_search: `"[keywords] startup funding traction"`
4. From results, identify 3-5 real competitors with URLs
5. Generate 3-5 data-backed reasons why this idea will struggle
6. Suggest 2-3 pivot directions based on gaps found

## Step 1b: Similar Projects Analysis (PROJECT mode)
1. Extract 2-3 keywords from the idea
2. Use web_search: `"[keywords] open source alternatives tools"`
3. From results, find 3-5 similar existing projects with URLs
4. Build a feature comparison: what they have, what's missing
5. Suggest 2-3 differentiation angles

## Step 2: GitHub Scout (both modes)
1. Use web_search: `"site:github.com [keywords]"` to find relevant repos
2. Use web_search: `"[keywords] github stars popular"` for a second angle
3. From results, pick top 5-8 real repos with star counts if available
4. Categorize: "Ready-to-use", "Useful libraries", "Reference implementations"
5. Pick one "Start here" recommendation with a specific reason

## Output Format — STARTUP Mode
```
--- MARKET REALITY CHECK ---

Your idea: [restated in one line]
Mode: Startup

Competitors:
  • [Name] ([url]) — [what they do, traction if found]
  • [Name] ([url]) — [what they do, traction if found]
  • [Name] ([url]) — [what they do, traction if found]

Why this will struggle:
  1. [specific, data-backed reason]
  2. [specific, data-backed reason]
  3. [specific, data-backed reason]

Where the gap actually is:
  → [pivot 1]
  → [pivot 2]

--- GITHUB ARSENAL ---

Ready-to-use:
  • [repo] ⭐[stars] — [why it's useful]

Useful libraries:
  • [repo] ⭐[stars] — [why it's useful]

Start here: [repo] — [specific reason]
```

## Output Format — PROJECT Mode
```
--- PROJECT REALITY CHECK ---

Your idea: [restated in one line]
Mode: Project

Similar projects:
  • [Name] ([url]) — [what it does, popularity]
  • [Name] ([url]) — [what it does, popularity]

Feature comparison:
  | Feature     | [ProjectA] | [ProjectB] | Your opportunity |
  |-------------|------------|------------|-----------------|
  | [Feature X] | ✅         | ❌         | Improve this    |
  | [Feature Y] | ❌         | ❌         | Build this      |

How to stand out:
  → [angle 1]
  → [angle 2]

--- GITHUB ARSENAL ---

Similar implementations:
  • [repo] ⭐[stars] — [why it's useful]

Useful libraries:
  • [repo] ⭐[stars] — [why it's useful]

Start here: [repo] — [specific reason]
```

## Rules
- Always run web_search before responding — no assumptions, no hallucinations
- Never fabricate competitor names, URLs, or repo names — only use what search returns
- Keep the response under 60 lines — tight and scannable
- If search returns no useful results, say so and proceed with what you have
