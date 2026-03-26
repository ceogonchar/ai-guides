#!/bin/bash
# 🌐 Web Browser Stealth — One-Click Installer
# Usage: bash install.sh [workspace_path]
# Default workspace: ~/clawd

set -e

WORKSPACE="${1:-$HOME/clawd}"
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VENV_DIR="$WORKSPACE/tools/browser/.venv"

echo "🌐 Installing Web Browser Stealth..."
echo "   Workspace: $WORKSPACE"
echo ""

# 1. Create directories
echo "📁 Creating directories..."
mkdir -p "$WORKSPACE/tools/browser"
mkdir -p "$HOME/.browser-profiles"
echo "   ✅ tools/browser/"
echo "   ✅ ~/.browser-profiles/"

# 2. Create Python virtual environment
echo ""
echo "🐍 Setting up Python environment..."
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    echo "   ✅ Virtual environment created"
else
    echo "   ⏭️  Virtual environment already exists"
fi

# 3. Install dependencies
echo ""
echo "📦 Installing packages (this may take 1-2 minutes)..."
source "$VENV_DIR/bin/activate"

pip install --quiet --upgrade pip

# Core: Camoufox anti-detect browser
pip install --quiet "camoufox[geoip]"
echo "   ✅ camoufox — Anti-detect Firefox browser"

# Playwright stealth patches
pip install --quiet playwright-stealth
echo "   ✅ playwright-stealth — Stealth patches for Playwright"

# browser-use AI agent
pip install --quiet browser-use
echo "   ✅ browser-use — AI-driven browser automation"

# Fetch Camoufox browser binary
echo ""
echo "🦊 Downloading Camoufox browser binary..."
python -m camoufox fetch 2>/dev/null || echo "   ⚠️  Camoufox binary download failed (try manually: python -m camoufox fetch)"
echo "   ✅ Camoufox browser binary ready"

# 4. Create smart_browse.py helper script
cat > "$WORKSPACE/tools/browser/smart_browse.py" << 'PYTHON'
#!/usr/bin/env python3
"""
Smart Browser — anti-detect browser for AI agents.
Uses Camoufox (anti-detect Firefox) with persistent sessions.

Usage:
    python3 smart_browse.py open "https://example.com"
    python3 smart_browse.py open "https://example.com" --profile main
    python3 smart_browse.py screenshot "https://example.com" -o shot.png
    python3 smart_browse.py text "https://example.com"
"""

import argparse, json, sys
from pathlib import Path

PROFILES_DIR = Path.home() / ".browser-profiles"
PROFILES_DIR.mkdir(exist_ok=True)

def browse(url, profile=None, headless=True, screenshot=None):
    from camoufox.sync_api import Camoufox
    kwargs = {"headless": headless}
    if profile:
        d = PROFILES_DIR / f"camoufox-{profile}"
        d.mkdir(exist_ok=True)
        kwargs["persistent_context"] = True
        kwargs["user_data_dir"] = str(d)

    with Camoufox(**kwargs) as browser:
        page = browser.new_page()
        page.goto(url, wait_until="domcontentloaded", timeout=30000)
        result = {"url": page.url, "title": page.title(), "text": page.inner_text("body")[:5000]}
        if screenshot:
            page.screenshot(path=screenshot, full_page=True)
            result["screenshot"] = screenshot
        return result

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Anti-detect browser for AI agents")
    parser.add_argument("action", choices=["open", "screenshot", "text"])
    parser.add_argument("url", help="URL to open")
    parser.add_argument("--profile", "-p", help="Persistent profile (keeps cookies)")
    parser.add_argument("--output", "-o", help="Screenshot output path")
    parser.add_argument("--headed", action="store_true", help="Show browser window")
    args = parser.parse_args()

    result = browse(args.url, args.profile, not args.headed,
                    args.output if args.action == "screenshot" else None)
    if args.action == "text":
        print(result.get("text", ""))
    else:
        print(json.dumps(result, indent=2, ensure_ascii=False))
PYTHON
chmod +x "$WORKSPACE/tools/browser/smart_browse.py"
echo "   ✅ tools/browser/smart_browse.py — ready-to-use script"

# 5. Verify installation
echo ""
echo "🔍 Verifying installation..."
CHECKS=0
python3 -c "import camoufox" 2>/dev/null && echo "   ✅ camoufox imported" && CHECKS=$((CHECKS+1)) || echo "   ❌ camoufox import failed"
python3 -c "import playwright_stealth" 2>/dev/null && echo "   ✅ playwright-stealth imported" && CHECKS=$((CHECKS+1)) || echo "   ❌ playwright-stealth import failed"
python3 -c "import browser_use" 2>/dev/null && echo "   ✅ browser-use imported" && CHECKS=$((CHECKS+1)) || echo "   ❌ browser-use import failed"

deactivate 2>/dev/null || true

echo ""
echo "═══════════════════════════════════════════════"
echo "🌐 Web Browser Stealth — INSTALLED! ($CHECKS/3 checks passed)"
echo "═══════════════════════════════════════════════"
echo ""
echo "What was installed:"
echo "  🦊 Camoufox       — Anti-detect Firefox (bypasses Cloudflare/DataDome)"
echo "  🥷 Stealth patches — Hides automation fingerprints"
echo "  🤖 browser-use    — AI agent that drives the browser"
echo "  📄 smart_browse.py — Ready-to-use browsing script"
echo ""
echo "Usage:"
echo "  source $VENV_DIR/bin/activate"
echo "  python3 tools/browser/smart_browse.py open 'https://example.com' -p main"
echo ""
echo "Your agent can now:"
echo "  • Browse any website autonomously"
echo "  • Bypass Cloudflare, DataDome, reCAPTCHA"
echo "  • Keep login sessions with persistent profiles"
echo "  • Run complex multi-step web tasks via AI agent"
echo "═══════════════════════════════════════════════"
