# meet-to-notion

Локальний пайплайн: запис Google Meet → Whisper → комерційна пропозиція → Notion.

## Структура репо

```
transcribe.py                          ← основний скрипт (копіюється в ~/.claude/scripts/)
setup.sh                               ← встановлює все одною командою
prompts/commercial-proposal-template.md ← заготовка шаблону КП
.claude/skills/transcription-pipeline/ ← скіл (копіюється в ~/.claude/skills/)
```

## Встановлення (для контриб'юторів)

```bash
bash setup.sh
```

Після цього репо можна видалити — всі файли скопійовано в `~/.claude/`.

## Розробка

Якщо вносиш зміни в `transcribe.py` або скіл — перезапусти `setup.sh` щоб оновити `~/.claude/`.

## Модель

- `large-v3-turbo` — найкращий баланс якості/швидкості для української
- Завантажується при першому запуску (~800 MB) в `~/.cache/whisper/`
- `fp16=False` на Apple Silicon та CPU (стабільніше)
- Для зміни мови: константа `LANGUAGE` у `transcribe.py`
