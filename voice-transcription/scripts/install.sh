#!/bin/bash
# 🎙️ Voice Transcription — One-Click Installer
# Usage: bash install.sh [workspace_path]

set -e

WORKSPACE="${1:-$HOME/clawd}"
VENV_DIR="$WORKSPACE/tools/voice/.venv"
BIN_DIR="$WORKSPACE/tools/bin"

echo "🎙️ Installing Voice Transcription..."
echo "   Workspace: $WORKSPACE"
echo ""

# 1. Create directories
mkdir -p "$WORKSPACE/tools/voice"
mkdir -p "$BIN_DIR"

# 2. Check for ffmpeg
echo "🔍 Checking ffmpeg..."
if command -v ffmpeg &>/dev/null; then
    echo "   ✅ ffmpeg found: $(which ffmpeg)"
elif [ -f "$BIN_DIR/ffmpeg" ]; then
    echo "   ✅ ffmpeg found: $BIN_DIR/ffmpeg"
else
    echo "   📦 Installing ffmpeg..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install ffmpeg 2>/dev/null || echo "   ⚠️  Install ffmpeg manually: brew install ffmpeg"
    else
        sudo apt-get install -y ffmpeg 2>/dev/null || echo "   ⚠️  Install ffmpeg manually: apt install ffmpeg"
    fi
fi

# 3. Create virtual environment
echo ""
echo "🐍 Setting up Python environment..."
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    echo "   ✅ Virtual environment created"
else
    echo "   ⏭️  Virtual environment already exists"
fi

source "$VENV_DIR/bin/activate"
pip install --quiet --upgrade pip

# 4. Detect platform and install appropriate Whisper
echo ""
echo "📦 Installing Whisper..."

IS_APPLE_SILICON=false
if [[ "$OSTYPE" == "darwin"* ]] && [[ "$(uname -m)" == "arm64" ]]; then
    IS_APPLE_SILICON=true
fi

if $IS_APPLE_SILICON; then
    echo "   🍎 Apple Silicon detected — installing MLX Whisper (GPU accelerated)"
    pip install --quiet mlx-whisper
    echo "   ✅ mlx-whisper installed"
else
    echo "   🖥️  Non-Apple platform — installing faster-whisper (CPU optimized)"
fi

# Always install faster-whisper as fallback
pip install --quiet faster-whisper
echo "   ✅ faster-whisper installed (CPU fallback)"

# 5. Create MLX transcription script
cat > "$WORKSPACE/tools/voice/transcribe_mlx.py" << 'PYTHON'
#!/usr/bin/env python3
"""Fast speech-to-text using MLX Whisper (Apple Silicon GPU).
~7s for tiny, ~15s for small (vs 30-40s CPU whisper).
"""
import os, sys

TOOLS_BIN = os.path.join(os.path.dirname(os.path.dirname(__file__)), "bin")
os.environ["PATH"] = TOOLS_BIN + ":" + os.environ.get("PATH", "")

import mlx_whisper

def transcribe(audio_path, language="ru", model="mlx-community/whisper-tiny"):
    result = mlx_whisper.transcribe(audio_path, language=language, path_or_hf_repo=model)
    return result["text"].strip()

if __name__ == "__main__":
    audio = sys.argv[1]
    lang = sys.argv[2] if len(sys.argv) > 2 else "ru"
    model = sys.argv[3] if len(sys.argv) > 3 else "mlx-community/whisper-tiny"
    print(transcribe(audio, lang, model))
PYTHON
chmod +x "$WORKSPACE/tools/voice/transcribe_mlx.py"

# 6. Create CPU fallback script
cat > "$WORKSPACE/tools/voice/transcribe.py" << 'PYTHON'
#!/usr/bin/env python3
"""Speech-to-text using faster-whisper (CPU, works everywhere)."""
import os, sys

TOOLS_BIN = os.path.join(os.path.dirname(os.path.dirname(__file__)), "bin")
os.environ["PATH"] = TOOLS_BIN + ":" + os.environ.get("PATH", "")

from faster_whisper import WhisperModel

def transcribe(audio_path, language="ru", model_size="small"):
    model = WhisperModel(model_size, device="cpu", compute_type="int8")
    segments, info = model.transcribe(audio_path, language=language)
    return " ".join(seg.text.strip() for seg in segments)

if __name__ == "__main__":
    audio = sys.argv[1]
    lang = sys.argv[2] if len(sys.argv) > 2 else "ru"
    model = sys.argv[3] if len(sys.argv) > 3 else "small"
    print(transcribe(audio, lang, model))
PYTHON
chmod +x "$WORKSPACE/tools/voice/transcribe.py"

# 7. Verify
echo ""
echo "🔍 Verifying installation..."
CHECKS=0

if $IS_APPLE_SILICON; then
    python3 -c "import mlx_whisper" 2>/dev/null && echo "   ✅ mlx-whisper ready" && CHECKS=$((CHECKS+1)) || echo "   ❌ mlx-whisper failed"
fi
python3 -c "from faster_whisper import WhisperModel" 2>/dev/null && echo "   ✅ faster-whisper ready" && CHECKS=$((CHECKS+1)) || echo "   ❌ faster-whisper failed"

deactivate 2>/dev/null || true

echo ""
echo "═══════════════════════════════════════════════"
echo "🎙️ Voice Transcription — INSTALLED!"
echo "═══════════════════════════════════════════════"
echo ""
echo "What was installed:"
if $IS_APPLE_SILICON; then
echo "  🍎 MLX Whisper    — GPU-accelerated (~7s per minute of audio)"
fi
echo "  🖥️  faster-whisper — CPU fallback (works everywhere)"
echo "  📄 transcribe_mlx.py — Apple Silicon script"
echo "  📄 transcribe.py     — CPU fallback script"
echo ""
echo "Usage:"
echo "  source $VENV_DIR/bin/activate"
echo "  python3 tools/voice/transcribe_mlx.py audio.ogg        # MLX"
echo "  python3 tools/voice/transcribe.py audio.ogg            # CPU"
echo "  python3 tools/voice/transcribe.py audio.ogg en small   # English"
echo "═══════════════════════════════════════════════"
