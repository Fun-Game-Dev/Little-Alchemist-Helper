#!/usr/bin/env python3
"""Собирает assets/fusion_onyx_stats.json из assets/data_from_exel.txt (TSV).

Синтетические материалы Onyx в каталоге ограничиваются allowlist `:occ:` из
assets/data/pack_schedule_occasions.json (генерируется build_shop_packs_json.dart);
эта таблица — полные пары классов для превью фьюжна, не список допустимых карт.
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "data_from_exel.txt"
DST = ROOT / "assets" / "fusion_onyx_stats.json"


def main() -> None:
    out: dict[str, list[list[int]]] = {}
    for i, line in enumerate(SRC.read_text(encoding="utf-8").splitlines()):
        parts = line.split("\t")
        if i == 0 or len(parts) < 14:
            continue
        a, b = parts[3].strip(), parts[4].strip()
        if not a or not b:
            continue
        try:
            ba0, ba1, ba2 = int(parts[8]), int(parts[9]), int(parts[10])
            bd0, bd1, bd2 = int(parts[11]), int(parts[12]), int(parts[13])
        except (ValueError, IndexError):
            continue
        key = f"{a}|{b}" if a <= b else f"{b}|{a}"
        out[key] = [[ba0, bd0], [ba1, bd1], [ba2, bd2]]
    DST.write_text(json.dumps(out, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"wrote {len(out)} entries -> {DST} ({DST.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
