#!/usr/bin/env bash
# html-ppt :: render.sh — headless Chrome screenshot(s)
#
# Usage:
#   render.sh <html-file>                     # one PNG, slide 1
#   render.sh <html-file> <N>                 # N PNGs, slides 1..N, via #/k
#   render.sh <html-file> all                 # autodetect .slide count
#   render.sh <html-file> <N> <out-dir>       # custom output dir
#
# Cross-platform: macOS / Windows (Git Bash, MSYS, Cygwin) / Linux.
# Override detection with:  CHROME_BIN=/path/to/chrome render.sh ...

set -euo pipefail

# ---------------------------------------------------------------- chrome ----
find_chrome() {
  # 1) explicit override wins
  if [[ -n "${CHROME_BIN:-}" ]]; then
    if [[ -x "$CHROME_BIN" ]]; then printf '%s' "$CHROME_BIN"; return 0; fi
    echo "error: CHROME_BIN is set but not executable: $CHROME_BIN" >&2
    return 1
  fi

  local candidates=(
    # macOS
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary"
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
    # Windows (Git Bash / MSYS style paths)
    "/c/Program Files/Google/Chrome/Application/chrome.exe"
    "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
    "${LOCALAPPDATA:-}/Google/Chrome/Application/chrome.exe"
    "/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
    "/c/Program Files/Microsoft/Edge/Application/msedge.exe"
    # Linux
    "/usr/bin/google-chrome"
    "/usr/bin/google-chrome-stable"
    "/usr/bin/chromium"
    "/usr/bin/chromium-browser"
    "/usr/bin/microsoft-edge"
  )

  local c
  for c in "${candidates[@]}"; do
    [[ -n "$c" && -x "$c" ]] && { printf '%s' "$c"; return 0; }
  done

  # 3) fall back to PATH
  for c in google-chrome google-chrome-stable chromium chromium-browser chrome msedge; do
    if command -v "$c" >/dev/null 2>&1; then
      printf '%s' "$(command -v "$c")"; return 0
    fi
  done

  return 1
}

if ! CHROME="$(find_chrome)"; then
  cat >&2 <<'EOF'
error: Chrome/Chromium/Edge not found.

Set CHROME_BIN to your browser binary and retry, e.g.

  Windows (Git Bash):
    CHROME_BIN="/c/Program Files/Google/Chrome/Application/chrome.exe" \
      scripts/render.sh deck/index.html all

  macOS:
    CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
      scripts/render.sh deck/index.html all
EOF
  exit 1
fi

# ------------------------------------------------------------ path helper ----
# On Windows, chrome.exe does not understand MSYS paths (/c/foo). Convert.
IS_WIN=0
case "$(uname -s 2>/dev/null || echo unknown)" in
  MINGW*|MSYS*|CYGWIN*) IS_WIN=1 ;;
esac

to_native() {
  # $1 = POSIX path -> native path (Windows: C:\foo\bar)
  if [[ "$IS_WIN" -eq 1 ]] && command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$1"
  else
    printf '%s' "$1"
  fi
}

to_file_url() {
  # $1 = absolute POSIX path -> file:// URL usable by the browser
  if [[ "$IS_WIN" -eq 1 ]] && command -v cygpath >/dev/null 2>&1; then
    # cygpath -m gives C:/foo/bar (forward slashes) — ideal for file:///
    printf 'file:///%s' "$(cygpath -m "$1")"
  else
    printf 'file://%s' "$1"
  fi
}

# ------------------------------------------------------------------ args ----
FILE="${1:-}"
if [[ -z "$FILE" ]]; then
  echo "usage: render.sh <html> [N|all] [out-dir]" >&2
  exit 1
fi
if [[ ! -f "$FILE" ]]; then
  echo "error: $FILE not found" >&2
  exit 1
fi

COUNT="${2:-1}"
OUT="${3:-}"

ABS="$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")"
STEM="$(basename "${FILE%.*}")"
URL_BASE="$(to_file_url "$ABS")"

if [[ "$COUNT" == "all" ]]; then
  # Match class="slide" and class="slide center tc" etc., but NOT class="slide-number".
  COUNT="$(grep -oE 'class="slide( [^"]*)?"' "$FILE" | wc -l | tr -d '[:space:]')"
  [[ -z "$COUNT" || "$COUNT" -lt 1 ]] && COUNT=1
fi

if [[ -z "$OUT" && "$COUNT" -gt 1 ]]; then
  OUT="$(dirname "$FILE")/${STEM}-png"
fi
# Multi-slide: $OUT is a directory — create it whether defaulted or passed as $3.
# Single slide: $OUT is a file path, so leave it alone.
[[ -n "$OUT" && "$COUNT" -gt 1 ]] && mkdir -p "$OUT"

# ---------------------------------------------------------------- render ----
abs_path() {
  # $1 = possibly relative path -> absolute POSIX path (file need not exist yet)
  local d b
  d="$(dirname "$1")"; b="$(basename "$1")"
  printf '%s/%s' "$(cd "$d" && pwd)" "$b"
}

render_one() {
  local url="$1" target="$2"
  local abs_target native_target
  # Chrome resolves --screenshot relative to its own cwd, so always pass an
  # absolute path.
  abs_target="$(abs_path "$target")"
  native_target="$(to_native "$abs_target")"

  "$CHROME" \
    --headless=new \
    --disable-gpu \
    --hide-scrollbars \
    --no-sandbox \
    --virtual-time-budget=4000 \
    --window-size=1920,1080 \
    --screenshot="$native_target" \
    "$url" >/dev/null 2>&1 || true

  if [[ -f "$abs_target" ]]; then
    echo "  ✔ $target"
  else
    echo "  ✘ failed: $target" >&2
    return 1
  fi
}

echo "chrome: $CHROME"

FAILED=0
if [[ "$COUNT" == "1" ]]; then
  OUT_FILE="${OUT:-$(dirname "$FILE")/${STEM}.png}"
  render_one "$URL_BASE" "$OUT_FILE" || FAILED=1
else
  for i in $(seq 1 "$COUNT"); do
    render_one "${URL_BASE}#/$i" "$OUT/${STEM}_$(printf '%02d' "$i").png" || FAILED=1
  done
fi

if [[ "$FAILED" -eq 1 ]]; then
  echo "done with errors: some slides failed to render from $FILE" >&2
  exit 1
fi

echo "done: rendered $COUNT slide(s) from $FILE"
