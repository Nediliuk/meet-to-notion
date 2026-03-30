#!/usr/bin/env python3
"""
transcribe.py — local Whisper transcription for meet-to-notion pipeline

Model: large-v3-turbo | Language: Ukrainian | No API key required
Runs on Apple Silicon (MPS), NVIDIA (CUDA), or CPU.

Usage:
    python3 transcribe.py <audio_file>

Output:
    - Transcript text → stdout (for Claude Code to capture)
    - Status messages → stderr
    - Saved file → ./transcripts/<filename>.txt
"""

import sys
from pathlib import Path

SUPPORTED_FORMATS = {".mp4", ".m4a", ".mov", ".mp3", ".wav", ".ogg", ".flac", ".webm"}
MODEL_NAME = "large-v3-turbo"
LANGUAGE = "uk"


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def validate_input(path_str: str) -> Path:
    if not path_str:
        eprint("Usage: python3 transcribe.py <audio_file>")
        sys.exit(1)

    path = Path(path_str)

    if not path.exists():
        eprint(f"Помилка: файл не знайдено: {path}")
        sys.exit(1)

    if path.suffix.lower() not in SUPPORTED_FORMATS:
        eprint(f"Помилка: непідтримуваний формат '{path.suffix}'")
        eprint(f"Підтримуються: {', '.join(sorted(SUPPORTED_FORMATS))}")
        sys.exit(1)

    return path


def detect_device() -> tuple:
    """Returns (device_str, fp16_bool). fp16=True only on CUDA — MPS has instability with fp16."""
    try:
        import torch
        if torch.cuda.is_available():
            eprint("Пристрій: NVIDIA GPU (CUDA)")
            return "cuda", True
        if torch.backends.mps.is_available():
            eprint("Пристрій: Apple Silicon (MPS), fp16 вимкнено")
            return "mps", False
    except Exception:
        pass
    eprint("Пристрій: CPU")
    return "cpu", False


def load_model():
    try:
        import whisper
    except ImportError:
        eprint("Помилка: openai-whisper не встановлено.")
        eprint("Запусти: pip3 install 'openai-whisper>=20240930'")
        sys.exit(1)

    eprint(f"Завантаження моделі {MODEL_NAME}...")
    eprint("(Перший запуск завантажує ~800 MB — зачекай кілька хвилин)")
    return whisper.load_model(MODEL_NAME)


def run_transcription(model, audio_path: Path, fp16: bool) -> str:
    eprint(f"Транскрибування: {audio_path.name} ...")
    try:
        result = model.transcribe(
            str(audio_path),
            language=LANGUAGE,
            fp16=fp16,
            verbose=False,
        )
        return result["text"].strip()
    except RuntimeError as e:
        if "out of memory" in str(e).lower():
            eprint("")
            eprint("Помилка: не вистачає пам'яті для моделі large-v3-turbo.")
            eprint("Спробуй меншу модель — зміни MODEL_NAME на 'medium' у скрипті.")
            sys.exit(1)
        raise


def save_transcript(text: str, audio_path: Path) -> Path:
    output_dir = Path("./transcripts")
    output_dir.mkdir(exist_ok=True)
    out_path = output_dir / f"{audio_path.stem}.txt"
    out_path.write_text(text, encoding="utf-8")
    return out_path


def main():
    path_str = sys.argv[1] if len(sys.argv) > 1 else ""
    audio_path = validate_input(path_str)

    device, fp16 = detect_device()
    model = load_model()
    text = run_transcription(model, audio_path, fp16)
    out_path = save_transcript(text, audio_path)

    eprint(f"Збережено: {out_path}")
    eprint("")

    # Transcript text goes to stdout — Claude Code captures this
    print(text)


if __name__ == "__main__":
    main()
