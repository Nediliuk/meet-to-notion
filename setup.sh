#!/usr/bin/env bash
set -e

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

echo ""
echo -e "${BOLD}=== meet-to-notion setup ===${RESET}"
echo ""

# ── 1. macOS check ────────────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
    echo -e "${YELLOW}Увага: скрипт тестувався тільки на macOS.${RESET}"
fi

# ── 2. Homebrew ───────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    echo -e "${RED}Помилка: Homebrew не знайдено.${RESET}"
    echo "Встанови з https://brew.sh і запусти setup.sh знову."
    exit 1
fi
echo -e "${GREEN}✓${RESET} Homebrew"

# ── 3. ffmpeg ─────────────────────────────────────────────────────────────────
if ! command -v ffmpeg &>/dev/null; then
    echo "Встановлення ffmpeg..."
    brew install ffmpeg
else
    echo -e "${GREEN}✓${RESET} ffmpeg"
fi

# ── 4. Python 3.9+ ────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}Помилка: python3 не знайдено.${RESET}"
    echo "Встанови Python 3.9+ через https://brew.sh: brew install python3"
    exit 1
fi

PY_OK=$(python3 -c "import sys; print(sys.version_info >= (3,9))")
if [[ "$PY_OK" != "True" ]]; then
    echo -e "${RED}Помилка: потрібен Python 3.9+${RESET}"
    echo "Поточна версія: $(python3 --version)"
    exit 1
fi
echo -e "${GREEN}✓${RESET} Python $(python3 --version | cut -d' ' -f2)"

# ── 5. openai-whisper ─────────────────────────────────────────────────────────
echo "Встановлення openai-whisper..."
pip3 install "openai-whisper>=20240930" --quiet
echo -e "${GREEN}✓${RESET} openai-whisper"

# ── 6. Copy files to ~/.claude/ ───────────────────────────────────────────────
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$HOME/.claude/scripts/prompts"
mkdir -p "$HOME/.claude/skills"

cp "$REPO_DIR/transcribe.py" "$HOME/.claude/scripts/transcribe.py"
echo -e "${GREEN}✓${RESET} ~/.claude/scripts/transcribe.py"

cp "$REPO_DIR/prompts/commercial-proposal-template.md" \
   "$HOME/.claude/scripts/prompts/commercial-proposal-template.md"
echo -e "${GREEN}✓${RESET} ~/.claude/scripts/prompts/commercial-proposal-template.md"

cp -r "$REPO_DIR/.claude/skills/transcription-pipeline" \
   "$HOME/.claude/skills/transcription-pipeline"
echo -e "${GREEN}✓${RESET} ~/.claude/skills/transcription-pipeline/"

# ── 7. Add snippet to ~/.claude/CLAUDE.md ────────────────────────────────────
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
MARKER="## meet-to-notion pipeline"

if grep -q "$MARKER" "$CLAUDE_MD" 2>/dev/null; then
    echo -e "${GREEN}✓${RESET} ~/.claude/CLAUDE.md (вже містить секцію)"
else
    cat >> "$CLAUDE_MD" << 'EOF'

## meet-to-notion pipeline

Скрипт транскрипції: `~/.claude/scripts/transcribe.py`
Скіл: `~/.claude/skills/transcription-pipeline/`

Запуск: `python3 ~/.claude/scripts/transcribe.py <recording.mp4>`
- Transcript → stdout (Claude Code перехоплює) + `./transcripts/<name>.txt`
- Модель: Whisper large-v3-turbo (локально, без API ключа)
- Мова: українська. Змінити: константа LANGUAGE у скрипті.
- Apple Silicon / CPU: fp16 вимкнено автоматично.

Перший запуск завантажить ~800 MB моделі в ~/.cache/whisper/

Після встановлення скажи Claude Code: "налаштуй КП шаблон"
EOF
    echo -e "${GREEN}✓${RESET} ~/.claude/CLAUDE.md оновлено"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}Встановлення завершено!${RESET}"
echo ""
echo "Наступні кроки:"
echo "  1. Відкрий Claude Code (будь-яка папка)"
echo "  2. Напиши: ${BOLD}налаштуй КП шаблон${RESET}"
echo "     Claude запитає приклади твоїх КП і налаштує шаблон"
echo ""
echo "Після налаштування:"
echo "  Напиши: ${BOLD}зроби пропозицію з meeting.mp4${RESET}"
echo ""
