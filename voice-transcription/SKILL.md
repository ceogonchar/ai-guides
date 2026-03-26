---
name: voice-transcription
description: >-
  Fast local speech-to-text for OpenClaw agents using Whisper. Transcribe voice
  messages, audio files, meeting recordings in any language. Supports MLX (Apple
  Silicon GPU, ~7 seconds) and CPU fallback. Use when your agent receives voice
  notes, needs to transcribe audio, or process speech input. Triggers: "transcribe",
  "voice to text", "speech recognition", "whisper", "voice note", "audio transcription".
---

# 🎙️ Voice Transcription — Local Speech-to-Text for AI Agents

Transcribe voice messages, audio files, and recordings locally — fast, private, free. No API keys needed.

## One-Click Install

```bash
bash scripts/install.sh
```

Installs Whisper (MLX for Apple Silicon or CPU fallback), ffmpeg, and ready-to-use transcription scripts.

**What gets installed:**
- `tools/voice/transcribe_mlx.py` — MLX GPU transcription (~7 sec for 1 min audio)
- `tools/voice/transcribe.py` — CPU fallback (~30 sec for 1 min audio)
- `tools/bin/ffmpeg` — audio conversion (if not already installed)
- Python virtual environment with all dependencies

## How It Works

```
Voice Note (.ogg) → ffmpeg → Whisper → Text
                              ↑
                    MLX (Apple Silicon) or CPU
```

### Apple Silicon (M1/M2/M3/M4) — MLX Whisper
- Uses GPU acceleration via Apple's MLX framework
- ~7 seconds for a 1-minute voice note (tiny model)
- ~15 seconds with small model (better accuracy)

### CPU Fallback — faster-whisper
- Works on any machine (Linux, Intel Mac, VPS)
- ~30-40 seconds for a 1-minute voice note
- Uses CTranslate2 for optimized inference

## Usage

### From Command Line

```bash
source tools/voice/.venv/bin/activate

# MLX (Apple Silicon)
python3 tools/voice/transcribe_mlx.py audio.ogg
python3 tools/voice/transcribe_mlx.py audio.ogg en    # English
python3 tools/voice/transcribe_mlx.py audio.ogg ru    # Russian

# CPU fallback
python3 tools/voice/transcribe.py audio.ogg
python3 tools/voice/transcribe.py audio.ogg en small   # English, small model
```

### In Your Agent (AGENTS.md)

Add this to your `AGENTS.md` for automatic voice note handling:

```markdown
## Voice Notes (Telegram)
When a Telegram message includes an audio voice note (.ogg/opus):
1. Transcribe using `tools/voice/transcribe_mlx.py` (MLX GPU, ~7s)
2. Fallback: `tools/voice/transcribe.py` if MLX fails
3. Respond to the *content* of the voice note
4. If transcription fails, ask user to re-send
```

### From Python

```python
# MLX version
from tools.voice.transcribe_mlx import transcribe
text = transcribe("audio.ogg", language="en")

# CPU version
from tools.voice.transcribe import transcribe
text = transcribe("audio.ogg", language="en", model="small")
```

## Supported Formats

Any audio format supported by ffmpeg:
- `.ogg` (Telegram voice notes)
- `.mp3`, `.m4a`, `.wav`, `.flac`
- `.mp4`, `.webm` (extracts audio from video)

## Available Models

| Model | Size | Speed (MLX) | Speed (CPU) | Accuracy |
|-------|------|-------------|-------------|----------|
| `tiny` | 39MB | ~7s/min | ~15s/min | Good for clear speech |
| `small` | 244MB | ~15s/min | ~30s/min | Better accuracy |
| `medium` | 769MB | ~30s/min | ~60s/min | High accuracy |
| `large-v3` | 1.5GB | ~45s/min | ~120s/min | Best accuracy |

**Recommendation:** Start with `tiny` for voice notes (fast, usually enough). Use `small` for meetings or noisy audio.

## Supported Languages

Whisper supports 99+ languages. Most common:
- `en` — English
- `ru` — Russian
- `uk` — Ukrainian
- `es` — Spanish
- `de` — German
- `fr` — French
- `zh` — Chinese
- `ja` — Japanese
- `ar` — Arabic

Leave language empty for auto-detection.

## Integration with OpenClaw

OpenClaw already handles voice notes from Telegram natively. This skill enhances it with:
- Faster transcription (MLX vs cloud API)
- No API costs (100% local)
- Privacy (audio never leaves your machine)
- Multi-language support
- Customizable models

## Common Pitfalls

1. **Using large model for short voice notes** — Overkill. `tiny` is fast and accurate enough for 10-30 second messages.
2. **Missing ffmpeg** — The install script handles this, but if transcription fails with format errors, check `which ffmpeg`.
3. **Running MLX on non-Apple hardware** — MLX only works on Apple Silicon. The script auto-detects and falls back to CPU Whisper.
4. **Not activating venv** — Always `source tools/voice/.venv/bin/activate` before running scripts.
