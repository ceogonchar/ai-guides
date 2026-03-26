---
name: web-browser-stealth
description: >-
  Autonomous web browsing for OpenClaw agents with anti-detection and CAPTCHA bypass.
  Covers built-in browser tool, Camoufox (anti-detect Firefox), Playwright Stealth,
  browser-use AI agent, and multi-agent browser isolation. Use when your agent needs
  to navigate websites, fill forms, log into accounts, bypass Cloudflare/DataDome,
  or automate any web task end-to-end. Triggers: "browse website", "web automation",
  "captcha bypass", "cloudflare bypass", "anti-detect browser", "browser agent",
  "fill form", "login to site", "scrape website".
---

# 🌐 Web Browser Stealth — Autonomous Browsing for AI Agents

Make your OpenClaw agent browse the web like a human — navigating sites, filling forms, logging in, and bypassing anti-bot protection automatically.

## Architecture: 4 Levels of Browser Power

```
Level 1: web_fetch          → Simple page reading (no JS)
Level 2: browser tool       → Built-in headless Chrome (clicks, forms, screenshots)
Level 3: Camoufox           → Anti-detect Firefox (bypasses Cloudflare/DataDome)
Level 4: browser-use agent  → AI-driven browser automation (complex multi-step tasks)
```

**Start with Level 1, escalate only when needed.**

## Level 1: web_fetch (No Setup Required)

For reading page content — no browser needed:

```
# In your agent's instructions, just use the web_fetch tool:
web_fetch(url="https://example.com", extractMode="markdown")
```

✅ **Best for:** Reading articles, documentation, API responses, simple pages
❌ **Not for:** JavaScript-heavy sites, login-required pages, interactive forms

## Level 2: Built-in Browser Tool (No Setup Required)

OpenClaw includes a headless Chrome browser out of the box:

```
# Start browser
browser(action="start")

# Navigate to page
browser(action="navigate", targetUrl="https://example.com")

# Get page structure (DOM snapshot)
browser(action="snapshot", compact=true)

# Click an element (using ref from snapshot)
browser(action="act", request={kind:"click", ref:"e5"})

# Type into a field
browser(action="act", request={kind:"type", ref:"e3", text:"hello"})

# Take screenshot
browser(action="screenshot")
```

✅ **Best for:** Most websites, dashboards, forms, logged-in sessions
❌ **Not for:** Sites with aggressive bot detection (Cloudflare challenge, DataDome)

### Tips for Built-in Browser:
- Cookies persist between sessions in the browser profile
- Use `compact=true` on snapshots to save tokens
- Close popups/banners with `act(kind:"click")` before doing main task
- Always DECLINE cookie consent by default

## Level 3: Camoufox — Anti-Detect Firefox

When sites block regular browsers (Cloudflare, reCAPTCHA, DataDome), use Camoufox:

### Installation

```bash
# Create virtual environment
python3 -m venv tools/browser/.venv
source tools/browser/.venv/bin/activate

# Install Camoufox + Playwright Stealth
pip install camoufox[geoip] playwright-stealth

# Fetch Camoufox browser binary
python -m camoufox fetch
```

### Usage Script

Save as `tools/browser/smart_browse.py`:

```python
#!/usr/bin/env python3
"""Anti-detect browser for AI agents using Camoufox."""

import json
from pathlib import Path
from camoufox.sync_api import Camoufox

PROFILES_DIR = Path.home() / ".browser-profiles"
PROFILES_DIR.mkdir(exist_ok=True)

def browse(url: str, profile: str = None, screenshot: str = None):
    """Open URL with anti-detect browser."""
    kwargs = {"headless": True}
    if profile:
        profile_dir = PROFILES_DIR / f"camoufox-{profile}"
        profile_dir.mkdir(exist_ok=True)
        kwargs["persistent_context"] = True
        kwargs["user_data_dir"] = str(profile_dir)

    with Camoufox(**kwargs) as browser:
        page = browser.new_page()
        page.goto(url, wait_until="domcontentloaded", timeout=30000)

        result = {
            "url": page.url,
            "title": page.title(),
            "text": page.inner_text("body")[:5000]
        }

        if screenshot:
            page.screenshot(path=screenshot, full_page=True)
            result["screenshot"] = screenshot

        return result

if __name__ == "__main__":
    import sys
    url = sys.argv[1] if len(sys.argv) > 1 else "https://example.com"
    profile = sys.argv[2] if len(sys.argv) > 2 else None
    print(json.dumps(browse(url, profile), indent=2, ensure_ascii=False))
```

### Usage:

```bash
source tools/browser/.venv/bin/activate

# Basic browsing
python3 tools/browser/smart_browse.py "https://protected-site.com"

# With persistent profile (cookies saved between runs!)
python3 tools/browser/smart_browse.py "https://site.com" main

# Screenshot
python3 tools/browser/smart_browse.py "https://site.com" main /tmp/shot.png
```

### Why Camoufox Works:
- Real Firefox fingerprint (not Chromium — most bot detectors target Chrome)
- Randomized canvas, WebGL, audio fingerprints
- Realistic screen size, timezone, language headers
- GeoIP-based locale matching
- Persistent profiles keep cookies/sessions alive between runs

## Level 4: browser-use — AI-Driven Browser Agent

For complex multi-step tasks, use `browser-use` — an AI agent that controls the browser:

### Installation

```bash
source tools/browser/.venv/bin/activate
pip install browser-use langchain-google-genai
```

### Usage Script

```python
#!/usr/bin/env python3
"""AI browser agent — give it a task, it figures out the clicks."""

import asyncio
from browser_use import Agent, Browser
from langchain_google_genai import ChatGoogleGenerativeAI

async def run_task(task: str, url: str = None):
    browser = Browser()
    llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash")

    full_task = f"Go to {url} and {task}" if url else task

    agent = Agent(task=full_task, llm=llm, browser=browser)
    result = await agent.run()
    await browser.close()
    return result

if __name__ == "__main__":
    import sys
    task = sys.argv[1]
    url = sys.argv[2] if len(sys.argv) > 2 else None
    asyncio.run(run_task(task, url))
```

### Example Tasks:

```bash
# Log into a dashboard and extract data
python3 browser_agent.py "Log in with email user@example.com and password X, then export the monthly report"

# Fill out a multi-step form
python3 browser_agent.py "Fill out the insurance application with these details: Name: John, DOB: 1990-01-01..."

# Research across multiple pages
python3 browser_agent.py "Search for 'AI agents' on ProductHunt, find the top 5 results, get their URLs and descriptions"
```

## Multi-Agent Browser Isolation

When multiple sub-agents need browsers simultaneously, they interfere with each other. Solution: **give each agent its own browser on a separate port.**

### Available Ports:

| Port | Profile | Assignment |
|------|---------|------------|
| 9222 | main-agent | Main agent |
| 9223 | sub-agent-1 | Sub-agent #1 |
| 9224 | sub-agent-2 | Sub-agent #2 |
| 9225 | sub-agent-3 | Sub-agent #3 |

### Launch Isolated Browser:

```bash
# For sub-agent on port 9223:
google-chrome --remote-debugging-port=9223 \
  --user-data-dir="$HOME/.chrome-profiles/sub-agent-1" \
  --no-first-run --headless &
```

### In Sub-Agent Task:

```
"Use browser on port 9223. Navigate to site.com and extract the data."
```

### Rules:
- Main agent always uses default port (9222)
- Each sub-agent gets its own port (9223–9227)
- Close browser after task completion
- Never share ports between concurrent agents

## AGENTS.md Integration

Add to your `AGENTS.md`:

```markdown
## Browser Rules
**Browser = your tool. Act AUTONOMOUSLY.**

### DO without asking:
- ✅ Open any sites, navigate, search
- ✅ Click buttons, links, tabs
- ✅ Fill search forms, filters
- ✅ Close popups, banners, cookie notices (DECLINE by default)
- ✅ Log into accounts (if credentials are known)
- ✅ Download documents, PDFs, reports

### ASK first:
- ❓ Sending payments / financial transactions
- ❓ Publishing content (posts, comments)
- ❓ Signing documents

### Tool priority:
1. web_fetch — simple page reading
2. browser tool — headless Chrome, clicks, forms
3. Camoufox (smart_browse.py) — anti-detect for protected sites
4. browser-use agent — complex multi-step AI automation
```

## Handling Common Anti-Bot Challenges

### Cloudflare "Checking your browser"
→ Use **Camoufox** (Level 3). Its Firefox fingerprint passes Cloudflare JS challenge in most cases.

### reCAPTCHA v2/v3
→ Camoufox + persistent profile (builds trust score over time)
→ For v2 checkbox: browser-use agent can sometimes solve it
→ For hard CAPTCHAs: use a solving service API (2captcha, anti-captcha)

### DataDome / PerimeterX
→ Camoufox with GeoIP matching (`camoufox[geoip]`)
→ Rotate profiles if blocked

### Rate Limiting
→ Add delays between requests: `page.wait_for_timeout(2000)`
→ Use different profiles for different sites
→ Respect robots.txt for ethical scraping

## Common Pitfalls

1. **Using Chrome for everything** — Most anti-bot systems target Chromium. Switch to Camoufox (Firefox-based) for protected sites.
2. **No persistent profiles** — Each run looks like a brand new visitor = suspicious. Use `--profile` to maintain session cookies.
3. **Asking user to click buttons** — The agent should NEVER ask the user to interact with the browser. Click it yourself!
4. **Showing screenshots of every step** — Only show the final result, not intermediate steps.
5. **Forgetting to close browser** — Leaked browser processes eat memory. Always close when done.
6. **Same browser for parallel agents** — Agents switch each other's tabs. Use port isolation (9222-9227).
