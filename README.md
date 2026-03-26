# 🤖 AI Praktik — Ready-to-Use Skills for OpenClaw

Production-tested skills for the OpenClaw AI Agent Platform. Each skill is a self-contained package that gives your agent new capabilities.

## Installation (One-Click)

```bash
# 1. Clone this repo
git clone https://github.com/ceogonchar/ai-guides.git

# 2. Copy any skill to your workspace
cp -r ai-guides/hippocampus-memory ~/clawd/skills/

# 3. Run the installer (if the skill has one)
bash ~/clawd/skills/hippocampus-memory/scripts/install.sh

# Done! Your agent now has the skill.
```

Each skill includes a `scripts/install.sh` that sets up everything automatically — dependencies, configs, templates. Safe to re-run.

## Доступные skills & guides

| Skill / Guide | Описание |
|-------|----------|
| [hippocampus-memory](./hippocampus-memory/) | 🧠 Brain-inspired memory system — exponential decay, immunity rules, anti-amnesia, defragmentation |
| [web-browser-stealth](./web-browser-stealth/) | 🌐 Autonomous web browsing with anti-detect — Camoufox, CAPTCHA bypass, Cloudflare, multi-agent isolation |
| [memory-system](./memory-system/) | 📖 Detailed memory guide in Russian |
| [business-valuation](./business-valuation/) | AI-агент оценит твой бизнес и поможет продать на BizBuySell |

## Channel

📱 Telegram: [@ai_praktik_hub](https://t.me/ai_praktik_hub)

## Other Public Skills (separate repos)

| Skill | Description | Install |
|-------|-------------|---------|
| [vapi-calling-skill](https://github.com/ceogonchar/vapi-calling-skill) | 📞 AI phone calls — outbound/inbound via VAPI | `git clone` → copy to skills/ |
| [tesla-control](https://github.com/ceogonchar/tesla-control) | 🏎️ Tesla control via Telegram — lock, climate, charge | `git clone` → copy to skills/ |
| [garmin-coach](https://github.com/ceogonchar/garmin-coach) | 🏃 AI training coach for Garmin watches | `git clone` → copy to skills/ |

---
*Built with ❤️ in Miami by [@Gonchar1735](https://t.me/Gonchar1735)*
