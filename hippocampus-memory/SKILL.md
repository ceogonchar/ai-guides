---
name: hippocampus-memory
description: >-
  Brain-inspired memory system for OpenClaw agents. Solves AI amnesia with
  exponential decay scoring, immunity rules, daily journals, weekly compression,
  and automated defragmentation. Use when setting up agent memory, fighting
  context loss between sessions, or optimizing long-running agents. Triggers:
  "memory system", "agent forgets", "context loss", "anti-amnesia",
  "memory setup", "defragmentation", "hippocampus".
---

# 🧠 Hippocampus Memory System

A brain-inspired memory architecture that makes your AI agent remember like a human — important things persist, routine fades, and critical items are never forgotten.

## One-Click Install

```bash
bash scripts/install.sh
```

This automatically creates the full memory structure, copies configs, and sets up all files. Safe to re-run — won't overwrite existing data.

**What gets installed:**
- `memory/hippocampus/config.yaml` — decay rates, immunity rules, scoring
- `memory/consolidation/state.json` — shift handoff protocol
- `memory/decisions.md` — permanent decisions log (never deleted)
- `memory/facts.md` — people, accounts, infrastructure
- `MEMORY.md` — long-term curated memory
- `memory/weeks/` + `memory/archive/` — compression directories

## Architecture: 4 Memory Tiers

```
┌─────────────────────────────────────────┐
│         MEMORY.md  (Neocortex)          │
│   Long-term curated · < 100 lines      │
├─────────────────────────────────────────┤
│   decisions.md + facts.md  (Immune)     │
│   🔒 NEVER deleted · decisions & people │
├─────────────────────────────────────────┤
│   memory/weeks/W<N>.md  (Weekly)        │
│   Compressed weekly summaries           │
├─────────────────────────────────────────┤
│   memory/YYYY-MM-DD.md  (Hippocampus)   │
│   Daily raw journals · temporary        │
└─────────────────────────────────────────┘
```

### Tier 1: MEMORY.md — The Neocortex
Read at every session start. Contains only the most critical information:
- Identity, projects, goals
- Current critical tasks
- Key people and contacts
- Lessons and rules

**Rule:** Keep under 100 lines / 2000 tokens. If it grows — defragment.

### Tier 2: Daily Journals — memory/YYYY-MM-DD.md
One file per day. Raw logs of everything that happened. Use mandatory tags:

| Tag | Meaning | On Compression |
|-----|---------|----------------|
| `⚠️ DECISION` | Decision made | **Never deleted** → duplicate to decisions.md |
| `⚠️ LESSON` | Insight learned | **Never deleted** |
| `⚠️ BLOCKER` | Blocking issue | **Never deleted** until resolved |
| `📝 LOG` | Routine log | Deleted during compression |

### Tier 3: Immune Files
- **decisions.md** — Every decision ever made. Never deleted, even during compression.
- **facts.md** — People, IDs, accounts, infrastructure. Updated on every new contact.

### Tier 4: Weekly Summaries
Every Sunday: compress 7 daily journals → `memory/weeks/W<N>.md`
- Keep: decisions, lessons, mistakes, numbers, new contacts
- Delete: intermediate steps, debug logs, routine checks
- Originals → `memory/archive/`

## Hippocampus Protocol: How the Agent Decides What to Remember

Instead of remembering everything (expensive, noisy) or forgetting everything (useless), the agent uses **exponential decay** — like a real brain.

### The Formula

```
retention = importance × e^(-λ × age)
```

- `importance` — base importance score (0–1)
- `λ` (lambda) — decay rate (higher = forgets faster)
- `age` — age in conversation turns

### Scoring

```
final_score = base_importance × source_weight × (1 + emotional_modifier) × context_multiplier
```

See `references/config.yaml` for the full configuration including:
- **Decay rates** per message type (decisions decay slowly at 0.03, chit-chat fast at 0.50)
- **Source weights** (owner's direct message = 1.0, cron notification = 0.2)
- **Emotional modifiers** (frustration +30%, urgency +25%, praise +20%)
- **Immunity rules** (incomplete tasks NEVER decay, deadlines < 7 days NEVER decay)

### Three Index Tiers

| Score | Tier | Storage |
|-------|------|---------|
| ≥ 0.65 | 🟢 Full Keep | Complete text in context |
| 0.25–0.65 | 🟡 Compressed | Summary only |
| < 0.25 | 🔴 Sparse Pointer | Reference to file |

**No data is ever lost** — low-priority items move to files and can be retrieved on demand.

## Consolidation Cycles

| Cycle | Trigger | Actions |
|-------|---------|---------|
| **Light** | Every turn | Recalculate retention scores, update index |
| **Deep** | End of session / every 50 turns | Compress low-retention entries, extract decisions |
| **Archival** | Nightly / Sunday | Promote to MEMORY.md, generate weekly summary |

## State.json — Shift Handoff Protocol

The file `memory/consolidation/state.json` is a **note to the next session**:

```json
{
  "incomplete_tasks": [
    {"task": "Send report to client", "priority": "HIGH", "notes": "Draft ready"}
  ],
  "running_services": [
    {"name": "API server", "port": 3000, "pm2_name": "my-api"}
  ],
  "pending_questions": [
    {"question": "What's the April ad budget?", "deadline": "2026-04-01"}
  ],
  "last_session_summary": "Worked on report, need to add charts"
}
```

Agent reads this at startup and picks up where it left off.

## Anti-Amnesia Protocol

After ANY significant work (>5 minutes), mandatory checkpoint:

1. `memory/YYYY-MM-DD.md` → what was done, result
2. `state.json` → update incomplete_tasks
3. `decisions.md` → if a decision was made
4. `facts.md` → if a new contact/account appeared

**Checkpoint triggers** (if ANY of these happened — WRITE IT DOWN):
- ✅ File or project created/modified
- ✅ Process started/stopped
- ✅ Package installed
- ✅ Configuration changed
- ✅ Important information received
- ✅ Decision made

**Forbidden:**
- ❌ End session without writing to memory
- ❌ "Remember mentally" — it WILL disappear
- ❌ Sub-agent finishing without recording results

## Sleep-Time Compute

When the agent is idle (heartbeat with no tasks), it consolidates:

1. **Extract** — pull names → contacts/, tasks → active/, facts → MEMORY.md
2. **Update** — fill gaps in contacts, update task statuses
3. **Anticipate** — which tasks need attention soon? which patterns emerge?

## Defragmentation

When MEMORY.md grows beyond ~100 lines, run defragmentation:

1. **Scan** — count lines, analyze each section
2. **Score** — calculate retention for every item using hippocampus formula
3. **Consolidate** — compress, remove completed items, update numbers
4. **Archive** — old data → `memory/archive/`

Real-world result: **1,792 lines → 85 lines (21x compression)** with zero critical data loss.

## Add to AGENTS.md

Add this block to your workspace `AGENTS.md`:

```markdown
## Memory
- **Daily:** `memory/YYYY-MM-DD.md` — raw logs
- **Long-term:** `MEMORY.md` — curated
- **Decisions:** `memory/decisions.md` — NEVER deleted
- **Facts:** `memory/facts.md` — people, IDs, accounts
- **Weekly:** `memory/weeks/W<N>.md` — Sunday compression

### Tags (mandatory!)
- `⚠️ DECISION` → duplicate to decisions.md
- `⚠️ LESSON` — not deleted on compression
- `⚠️ BLOCKER` — not deleted until resolved
- `📝 LOG` — deleted on compression

### Anti-Amnesia
After any work >5 min — checkpoint:
1. memory/YYYY-MM-DD.md → what was done
2. state.json → update tasks
3. decisions.md → if decision made
```

## Common Pitfalls

1. **"I'll remember it"** — NO. Sessions restart. Files > brain.
2. **MEMORY.md grows to 500 lines** — Agent wastes 30% context just reading memory. Keep ≤100 lines.
3. **Sub-agents don't record results** — Add to every sub-agent task: "⚠️ Write results to memory/"
4. **Journals without tags** — Everything gets deleted on compression, including important decisions.
5. **Decisions in journals but not in decisions.md** — Journal gets compressed → decision lost forever.
