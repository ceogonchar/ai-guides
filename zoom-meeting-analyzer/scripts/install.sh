#!/bin/bash
# 📋 Zoom Meeting Analyzer — One-Click Installer
# Usage: bash install.sh [workspace_path]

set -e

WORKSPACE="${1:-$HOME/clawd}"

echo "📋 Installing Zoom Meeting Analyzer..."
echo "   Workspace: $WORKSPACE"
echo ""

# 1. Create directories
mkdir -p "$WORKSPACE/integrations/zoom"
echo "   ✅ integrations/zoom/"

# 2. Create credentials template (don't overwrite)
if [ ! -f "$WORKSPACE/integrations/zoom/credentials.json" ]; then
    cat > "$WORKSPACE/integrations/zoom/credentials.json" << 'EOF'
{
  "account_id": "YOUR_ZOOM_ACCOUNT_ID",
  "client_id": "YOUR_ZOOM_CLIENT_ID",
  "client_secret": "YOUR_ZOOM_CLIENT_SECRET",
  "notes": "Server-to-Server OAuth — create at marketplace.zoom.us/develop/create"
}
EOF
    echo "   ✅ credentials.json — template created (fill in your keys!)"
else
    echo "   ⏭️  credentials.json already exists (skipped)"
fi

# 3. Create Zoom API client
cat > "$WORKSPACE/integrations/zoom/api.py" << 'PYTHON'
#!/usr/bin/env python3
"""Zoom API — Server-to-Server OAuth — Recordings & Transcripts"""

import json, base64, urllib.request, urllib.parse, sys
from datetime import datetime, timedelta
from pathlib import Path

CREDS_PATH = Path(__file__).parent / "credentials.json"
with open(CREDS_PATH) as f:
    creds = json.load(f)

ACCOUNT_ID = creds["account_id"]
CLIENT_ID = creds["client_id"]
CLIENT_SECRET = creds["client_secret"]

_access_token = None
_token_expires = None

def get_access_token():
    global _access_token, _token_expires
    if _access_token and _token_expires and datetime.now() < _token_expires:
        return _access_token
    url = f"https://zoom.us/oauth/token?grant_type=account_credentials&account_id={ACCOUNT_ID}"
    auth = base64.b64encode(f"{CLIENT_ID}:{CLIENT_SECRET}".encode()).decode()
    req = urllib.request.Request(url, method="POST")
    req.add_header("Authorization", f"Basic {auth}")
    req.add_header("Content-Type", "application/x-www-form-urlencoded")
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read().decode())
        _access_token = data["access_token"]
        _token_expires = datetime.now() + timedelta(seconds=data["expires_in"] - 60)
        return _access_token

def api_request(endpoint, method="GET"):
    token = get_access_token()
    url = f"https://api.zoom.us/v2{endpoint}"
    req = urllib.request.Request(url, method=method)
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        return {"error": str(e), "code": e.code, "body": e.read().decode()}

def list_recordings(user_id="me", from_date=None, to_date=None):
    if not from_date:
        from_date = (datetime.now() - timedelta(days=30)).strftime("%Y-%m-%d")
    if not to_date:
        to_date = datetime.now().strftime("%Y-%m-%d")
    return api_request(f"/users/{user_id}/recordings?from={from_date}&to={to_date}")

def get_recording_transcript(download_url):
    token = get_access_token()
    url = f"{download_url}?access_token={token}" if "?" not in download_url else f"{download_url}&access_token={token}"
    req = urllib.request.Request(url)
    try:
        with urllib.request.urlopen(req) as resp:
            return resp.read().decode()
    except urllib.error.HTTPError as e:
        return f"Error: {e.code} - {e.read().decode()}"

def get_recent_transcripts(days=7):
    recordings = list_recordings(from_date=(datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d"))
    if "error" in recordings:
        return recordings
    transcripts = []
    for meeting in recordings.get("meetings", []):
        for f in meeting.get("recording_files", []):
            if f.get("file_type") == "TRANSCRIPT":
                text = get_recording_transcript(f["download_url"])
                transcripts.append({
                    "meeting_id": meeting["id"],
                    "topic": meeting["topic"],
                    "start_time": meeting["start_time"],
                    "duration": meeting.get("duration", 0),
                    "transcript": text
                })
    return {"count": len(transcripts), "transcripts": transcripts}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python api.py recordings [days]  — List recordings")
        print("  python api.py transcripts [days]  — Get transcripts")
        sys.exit(1)
    cmd = sys.argv[1]
    days = int(sys.argv[2]) if len(sys.argv) > 2 else 14
    if cmd == "recordings":
        print(json.dumps(list_recordings(from_date=(datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")), indent=2, ensure_ascii=False))
    elif cmd == "transcripts":
        print(json.dumps(get_recent_transcripts(days), indent=2, ensure_ascii=False))
    else:
        print(f"Unknown: {cmd}")
PYTHON
chmod +x "$WORKSPACE/integrations/zoom/api.py"
echo "   ✅ api.py — Zoom API client (recordings, transcripts)"

# 4. Verify
echo ""
echo "🔍 Verifying..."
python3 -c "import json, base64, urllib.request" 2>/dev/null && echo "   ✅ All Python dependencies available (stdlib only!)" || echo "   ❌ Python3 required"

echo ""
echo "═══════════════════════════════════════════════"
echo "📋 Zoom Meeting Analyzer — INSTALLED!"
echo "═══════════════════════════════════════════════"
echo ""
echo "What was installed:"
echo "  📄 api.py            — Zoom API client (zero dependencies!)"
echo "  📄 credentials.json  — Template (fill in your Zoom API keys)"
echo ""
echo "Next steps:"
echo "  1. Create a Zoom Server-to-Server OAuth app:"
echo "     → https://marketplace.zoom.us/develop/create"
echo "  2. Copy Account ID, Client ID, Client Secret"
echo "  3. Paste into: integrations/zoom/credentials.json"
echo "  4. Tell your agent: 'Analyze my last Zoom meeting'"
echo ""
echo "Usage:"
echo "  python3 integrations/zoom/api.py recordings 14"
echo "  python3 integrations/zoom/api.py transcripts 7"
echo ""
echo "Your agent will automatically:"
echo "  • Pull recordings and transcripts via API"
echo "  • Extract action items, decisions, promises"
echo "  • Generate coaching feedback"
echo "  • Track follow-ups across meetings"
echo "═══════════════════════════════════════════════"
