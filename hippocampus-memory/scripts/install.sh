#!/bin/bash
# 🧠 Hippocampus Memory — One-Click Installer
# Usage: bash install.sh [workspace_path]
# Default workspace: ~/clawd

set -e

WORKSPACE="${1:-$HOME/clawd}"
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🧠 Installing Hippocampus Memory System..."
echo "   Workspace: $WORKSPACE"
echo ""

# 1. Create memory directory structure
echo "📁 Creating memory directories..."
mkdir -p "$WORKSPACE/memory/hippocampus"
mkdir -p "$WORKSPACE/memory/consolidation"
mkdir -p "$WORKSPACE/memory/weeks"
mkdir -p "$WORKSPACE/memory/archive"
echo "   ✅ memory/hippocampus/"
echo "   ✅ memory/consolidation/"
echo "   ✅ memory/weeks/"
echo "   ✅ memory/archive/"

# 2. Copy config (don't overwrite if exists)
if [ ! -f "$WORKSPACE/memory/hippocampus/config.yaml" ]; then
    cp "$SKILL_DIR/references/config.yaml" "$WORKSPACE/memory/hippocampus/config.yaml"
    echo "   ✅ memory/hippocampus/config.yaml — decay rates, immunity rules"
else
    echo "   ⏭️  memory/hippocampus/config.yaml already exists (skipped)"
fi

# 3. Create state.json (don't overwrite)
if [ ! -f "$WORKSPACE/memory/consolidation/state.json" ]; then
    cp "$SKILL_DIR/references/state-template.json" "$WORKSPACE/memory/consolidation/state.json"
    echo "   ✅ memory/consolidation/state.json — shift handoff protocol"
else
    echo "   ⏭️  memory/consolidation/state.json already exists (skipped)"
fi

# 4. Create decisions.md if missing
if [ ! -f "$WORKSPACE/memory/decisions.md" ]; then
    cat > "$WORKSPACE/memory/decisions.md" << 'EOF'
# Decisions Log
> ⚠️ This file is IMMUNE — entries are NEVER deleted.
> Every decision made goes here for permanent record.

<!-- Add decisions in format:
## YYYY-MM-DD — Decision: [title]
[description, reasoning, who decided]
-->
EOF
    echo "   ✅ memory/decisions.md — permanent decisions log"
else
    echo "   ⏭️  memory/decisions.md already exists (skipped)"
fi

# 5. Create facts.md if missing
if [ ! -f "$WORKSPACE/memory/facts.md" ]; then
    cat > "$WORKSPACE/memory/facts.md" << 'EOF'
# Facts & Contacts
> Reference file for people, IDs, accounts, infrastructure.
> Updated automatically when new contacts appear.

## People
<!-- Name | Role | Contact | Notes -->

## Accounts & Services
<!-- Service | Login | Notes -->

## Infrastructure
<!-- System | Details -->
EOF
    echo "   ✅ memory/facts.md — people, accounts, infrastructure"
else
    echo "   ⏭️  memory/facts.md already exists (skipped)"
fi

# 6. Create MEMORY.md if missing
if [ ! -f "$WORKSPACE/MEMORY.md" ]; then
    cat > "$WORKSPACE/MEMORY.md" << 'EOF'
# MEMORY.md — Long-term Memory

## 🧠 About Me
<!-- Your identity, projects, goals -->

## 🔴 Critical Tasks
<!-- What needs to be done NOW -->

## ✅ Recently Completed
<!-- Recent achievements -->

## 👤 Key People
<!-- Important contacts and roles -->

## 💡 Lessons Learned
<!-- Rules and insights -->
EOF
    echo "   ✅ MEMORY.md — long-term curated memory"
else
    echo "   ⏭️  MEMORY.md already exists (skipped)"
fi

# 7. Create today's journal
TODAY=$(date +%Y-%m-%d)
if [ ! -f "$WORKSPACE/memory/$TODAY.md" ]; then
    echo "# $TODAY" > "$WORKSPACE/memory/$TODAY.md"
    echo "" >> "$WORKSPACE/memory/$TODAY.md"
    echo "## Hippocampus Memory System installed ✅" >> "$WORKSPACE/memory/$TODAY.md"
    echo "   ✅ memory/$TODAY.md — today's journal created"
else
    echo "   ⏭️  memory/$TODAY.md already exists (skipped)"
fi

echo ""
echo "═══════════════════════════════════════════════"
echo "🧠 Hippocampus Memory System — INSTALLED!"
echo "═══════════════════════════════════════════════"
echo ""
echo "What was installed:"
echo "  📄 config.yaml      — Decay rates, immunity rules, scoring formula"
echo "  📄 state.json       — Shift handoff protocol (incomplete tasks, services)"
echo "  📄 decisions.md     — Permanent decisions log (never deleted)"
echo "  📄 facts.md         — People, accounts, infrastructure reference"
echo "  📄 MEMORY.md        — Long-term curated memory (read every session)"
echo "  📁 memory/weeks/    — Weekly compression summaries"
echo "  📁 memory/archive/  — Archived daily journals"
echo ""
echo "Your agent will now:"
echo "  • Tag entries with ⚠️ DECISION / ⚠️ LESSON / 📝 LOG"
echo "  • Never forget active tasks (immunity rules)"
echo "  • Compress daily journals weekly (21x compression)"
echo "  • Hand off state between sessions via state.json"
echo ""
echo "Tell your agent: 'Set up memory using hippocampus protocol'"
echo "═══════════════════════════════════════════════"
