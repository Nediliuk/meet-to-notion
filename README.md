# meet-to-notion

**UA:** Локальний пайплайн: запис Google Meet → транскрипція → комерційна пропозиція → Notion.
**EN:** Local pipeline: Google Meet recording → transcription → commercial proposal → Notion.

```
recording.mp4  →  Whisper (local)  →  Claude Code  →  Notion page
```

Без API ключів. Без хмари. Все локально на твоєму Mac.

---

## Вимоги / Requirements

- macOS (tested on Apple Silicon + Intel)
- [Claude Code](https://claude.ai/code) desktop app
- [Homebrew](https://brew.sh)
- Python 3.9+
- Notion MCP підключений у Claude Code ([інструкція](https://modelcontextprotocol.io/docs))

---

## Встановлення / Installation

Відкрий Claude Code і вставте одне повідомлення:

```
Встанови meet-to-notion: https://github.com/YOUR_USERNAME/meet-to-notion
```

Claude Code автоматично:
1. Клонує репо у `/tmp/`
2. Запустить `setup.sh` (встановить ffmpeg, openai-whisper, скопіює скіл)
3. Видалить тимчасові файли

> **Перший запуск** завантажить модель Whisper (~800 MB) і PyTorch (~2 GB).
> Підключення до інтернету потрібне тільки один раз.

---

## Перше налаштування / First-time setup

Після встановлення скажи Claude Code:

```
налаштуй КП шаблон
```

Claude запитає 1–2 приклади твоїх попередніх комерційних пропозицій,
вивчить що в них статично (про компанію, чому ми), а що динамічно (під кожного клієнта),
і збереже персоналізований шаблон.

---

## Щоденне використання / Daily usage

1. Скачай запис зустрічі з Google Meet (`.mp4` або `.m4a`)
2. Відкрий Claude Code (в будь-якій папці)
3. Напиши:

```
зроби пропозицію з meeting-2026-03-30.mp4
```

Claude Code:
- Транскрибує запис локально через Whisper
- Згенерує комерційну пропозицію за твоїм шаблоном
- Уточнить деталі яких не вистачає
- З твого підтвердження створить сторінку в Notion і поверне посилання

Транскрипт також зберігається у `./transcripts/<назва_файлу>.txt`.

---

## Що встановлюється / What gets installed

| Що | Де | Розмір |
|---|---|---|
| `transcribe.py` | `~/.claude/scripts/` | ~3 KB |
| Скіл | `~/.claude/skills/transcription-pipeline/` | ~5 KB |
| Шаблон КП | `~/.claude/scripts/prompts/` | ~2 KB |
| `openai-whisper` + `torch` | pip site-packages | ~2 GB |
| `ffmpeg` | `/opt/homebrew/bin/` | ~100 MB |
| Модель `large-v3-turbo` | `~/.cache/whisper/` | ~800 MB |

---

## Advanced: запуск транскрипції напряму

```bash
python3 ~/.claude/scripts/transcribe.py /path/to/recording.mp4
```

Підтримувані формати: `.mp4 .m4a .mov .mp3 .wav .ogg .flac .webm`

Якщо M1 з 8 GB RAM і запис довгий — спробуй модель `medium`:
відкрий `~/.claude/scripts/transcribe.py`, зміни `MODEL_NAME = "medium"`.

---

## Ліцензія / License

MIT
