---
name: zoom-meeting-analyzer
description: >-
  Analyze Zoom meeting recordings automatically. Extracts action items, promises,
  decisions, coaching feedback, and key topics from any Zoom call. Uses Server-to-Server
  OAuth to pull recordings and transcripts via API. Use when you need meeting summaries,
  task extraction, follow-up tracking, or coaching analysis. Triggers: "analyze zoom",
  "meeting summary", "zoom recording", "what was discussed", "action items from meeting",
  "meeting notes", "zoom transcript".
---

# 📋 Zoom Meeting Analyzer — AI-Powered Meeting Intelligence

Turn your Zoom recordings into actionable intelligence — action items, promises, decisions, and coaching feedback. Fully automated via API.

## One-Click Install

```bash
bash scripts/install.sh
```

Sets up Zoom API access, creates analysis scripts, and configures your agent to process meetings automatically.

**What gets installed:**
- `integrations/zoom/api.py` — Zoom API client (recordings, transcripts)
- `integrations/zoom/analyze.py` — Meeting analysis script
- `integrations/zoom/credentials.json` — Template for API credentials

## Prerequisites: Zoom Server-to-Server OAuth App

Before installing, create a Zoom API app (one-time, ~5 minutes):

1. Go to [Zoom App Marketplace](https://marketplace.zoom.us/develop/create)
2. Click **"Server-to-Server OAuth"**
3. Name it anything (e.g., "Meeting Analyzer")
4. Copy these credentials:
   - **Account ID**
   - **Client ID**
   - **Client Secret**
5. Under **Scopes**, add:
   - `recording:read:admin` (read recordings)
   - `user:read:admin` (list users)
6. Activate the app

## Setup

After creating the app, add your credentials:

```json
// integrations/zoom/credentials.json
{
  "account_id": "your_account_id",
  "client_id": "your_client_id",
  "client_secret": "your_client_secret"
}
```

## What It Can Do

### 1. List Recent Recordings
```bash
python3 integrations/zoom/api.py recordings 14
```
Shows all recordings from the last 14 days with duration, topic, and file types.

### 2. Get Meeting Transcript
```bash
python3 integrations/zoom/api.py transcripts 7
```
Downloads VTT transcripts from the last 7 days.

### 3. Full Meeting Analysis

Tell your agent:
> "Analyze my last Zoom meeting"

The agent will:
1. Pull the latest recording via API
2. Download the transcript (VTT format)
3. Analyze the full text and extract:

| What | Description |
|------|-------------|
| 📋 **Action Items** | Who promised to do what, with deadlines |
| 🤝 **Decisions Made** | Agreements and commitments |
| ❓ **Open Questions** | Unanswered questions that need follow-up |
| 📊 **Key Topics** | Main themes discussed |
| ⏱️ **Time Analysis** | How time was spent (productive vs off-topic) |
| 🎯 **Coaching Feedback** | How the host performed (preparation, leadership, follow-through) |

### 4. Recurring Analysis (Cron)

Set up automatic analysis after every meeting:

```yaml
# In your OpenClaw cron config
schedule: "0 */4 * * *"  # Check every 4 hours
task: "Check for new Zoom recordings. If found, analyze and send summary."
```

## API Reference

```python
from integrations.zoom.api import (
    list_recordings,      # Get recordings for date range
    get_meeting_recordings,  # Get files for specific meeting
    get_recording_transcript,  # Download transcript text
    get_recent_transcripts,    # Get all transcripts from last N days
)

# List recordings from last 7 days
recordings = list_recordings(from_date="2026-03-20")

# Get transcript for specific meeting
for meeting in recordings["meetings"]:
    for file in meeting["recording_files"]:
        if file["file_type"] == "TRANSCRIPT":
            text = get_recording_transcript(file["download_url"])
```

## Output Example

```markdown
# Meeting Analysis: Team Standup (March 25, 2026)
Duration: 45 minutes | Participants: 5

## 📋 Action Items
1. @john — Send updated proposal to client (by Friday)
2. @sarah — Fix login bug on staging (today)
3. @host — Schedule follow-up with investor (this week)

## 🤝 Decisions
- Moving launch date to April 15
- Switching from Stripe to Square for payments

## ❓ Open Questions
- What's the Q2 marketing budget? (waiting on CFO)
- Do we need a second server? (needs load testing)

## 🎯 Coaching Feedback
- ✅ Good: Clear agenda, kept on time
- ⚠️ Improve: Let others speak more (host talked 60% of time)
- 💡 Tip: Send agenda 24h before next meeting
```

## Integration with Other Skills

Works great with:
- **🧠 Hippocampus Memory** — Decisions auto-saved to `decisions.md`
- **📞 Vapi Calling** — Follow up on action items by phone
- **💬 Telegram** — Send summary to team chat

## Available Recording Types

| Type | Extension | Use |
|------|-----------|-----|
| `shared_screen_with_speaker_view` | MP4 | Full video |
| `audio_only` | M4A | Audio for transcription |
| `audio_transcript` | VTT | Auto-generated transcript |
| `chat_file` | TXT | In-meeting chat messages |
| `timeline` | JSON | Speaker timeline data |

## Common Pitfalls

1. **No transcript available** — Zoom auto-transcription must be enabled in account settings (Settings → Recording → Audio transcript). Enable it BEFORE the meeting.
2. **Empty recordings list** — Server-to-Server OAuth requires admin scopes. Make sure your app has `recording:read:admin`.
3. **Transcript quality is poor** — Zoom's auto-transcription works best in English. For other languages, download the M4A audio and use the Voice Transcription skill (Whisper) for better results.
4. **Meeting not showing up** — Cloud recording must be enabled. Local recordings don't appear in the API.
5. **Analyzing very long meetings (3+ hours)** — Split the transcript into chunks to stay within model context limits. The analysis script handles this automatically.
