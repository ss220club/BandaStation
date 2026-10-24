"""Rebuild the technical clothing gap inventory from a Vox runtime audit JSON."""
import argparse
import collections
import csv
import hashlib
import json
import re
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))
from tools.dmi import Dmi

ASSETS = "icons/bandastation/mob/species/vox/clothing/"
MARKERS = {
    ASSETS + "uniform.dmi": ("NEEDS CONVERTED >>>>>", "source_marked_unconverted"),
    ASSETS + "feet.dmi": ("UNUSED >", "source_marked_unused"),
}
CATEGORIES = {"head": "Головные уборы", "mask": "Маски", "under": "Униформа", "shoes": "Обувь"}
FIELDS = (
    "name_ru", "type", "state", "category", "issue", "reason", "fitted",
    "fitted_icon", "native_icon", "greyscale_config", "source_marker",
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("inventory", type=Path, help="data/vox-clothing-inventory.json from test-vox.ps1")
    args = parser.parse_args()
    snapshot_date = datetime.fromtimestamp(
        args.inventory.stat().st_mtime, timezone(timedelta(hours=2)),
    ).date().isoformat()
    inventory = json.loads(args.inventory.read_text(encoding="utf-8"))
    items = inventory["items"]
    if len({item["type"] for item in items}) != len(items):
        raise ValueError("The runtime inventory contains duplicate item types.")

    sections = {}
    marker_summary = {}
    for relative, (marker, issue) in MARKERS.items():
        states = [state.name for state in Dmi.from_file(ROOT / relative).states]
        if states.count(marker) != 1:
            raise ValueError(f"Expected one {marker!r} marker in {relative}")
        after = set(states[states.index(marker) + 1:])
        sections[relative] = (after, marker, issue)
        marker_summary[issue] = {
            "file": relative, "marker": marker, "states_after_marker": len(after),
            "sha256": hashlib.sha256((ROOT / relative).read_bytes()).hexdigest(),
        }

    clothing_source = (ROOT / "modular_bandastation/species/code/clothing/items.dm").read_text(encoding="utf-8")
    supported_greyscale = set(re.findall(
        r"^\s*(/datum/greyscale_config/\S+)\s*=\s*/datum/greyscale_config/\S+/vox,?\s*$",
        clothing_source, re.M,
    ))
    if not supported_greyscale:
        raise ValueError("Could not read the Vox GAGS configuration map.")

    gaps = []
    category_counts = {}
    for category in CATEGORIES:
        rows = [item for item in items if item["category"] == category]
        category_counts[category] = {
            "visible": len(rows), "fitted_state_exists": sum(bool(item["fitted"]) for item in rows),
            "fallback": sum(not item["fitted"] for item in rows),
            "source_marked_unconverted": 0, "source_marked_unused": 0,
        }
    for item in items:
        marker = ""
        if not item["fitted"]:
            issue = "fallback"
            config = item.get("greyscale_config")
            if config and config not in supported_greyscale:
                reason = "unsupported_vox_greyscale_config"
            elif config:
                reason = "missing_state_in_supported_vox_greyscale"
            else:
                reason = "no_selected_vox_worn_state"
        else:
            section = sections.get(item["fitted_icon"])
            if not section or item["state"] not in section[0]:
                continue
            _, marker, issue = section
            reason = issue
            category_counts[item["category"]][issue] += 1
        gaps.append({
            **{field: item.get(field, "") for field in FIELDS},
            "name_ru": item.get("name_ru") or item["name"],
            "issue": issue, "reason": reason, "source_marker": marker,
        })
    gaps.sort(key=lambda item: (item["category"], item["issue"], item["type"]))
    output_dir = Path(__file__).resolve().parent
    csv_path = output_dir / "clothing-gaps.csv"
    with csv_path.open("w", encoding="utf-8-sig", newline="") as output:
        writer = csv.DictWriter(output, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(gaps)

    issue_counts = collections.Counter(item["issue"] for item in gaps)
    reason_counts = collections.Counter(item["reason"] for item in gaps)
    for issue in marker_summary:
        rows = [item for item in gaps if item["issue"] == issue]
        marker_summary[issue].update({"item_types": len(rows), "used_states": len({item["state"] for item in rows})})
    summary = {
        "date": snapshot_date, "scope": inventory["scope"],
        "inventory_sha256": hashlib.sha256(args.inventory.read_bytes()).hexdigest(),
        "visible_types": len(items), "fitted_state_exists": sum(bool(item["fitted"]) for item in items),
        "fallback": issue_counts["fallback"], "skipped_types": len(inventory["skipped"]),
        "gap_rows": len(gaps), "issues": dict(issue_counts), "reasons": dict(reason_counts),
        "categories": category_counts, "source_markers": marker_summary,
        "skipped_reasons": dict(collections.Counter(item["reason"] for item in inventory["skipped"])),
        "skipped": inventory["skipped"],
    }
    (output_dir / "clothing-gaps-summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8",
    )
    table = ["| Категория | Видимых типов | Найден fitted state | Fallback | После NEEDS CONVERTED | После UNUSED |",
             "|---|---:|---:|---:|---:|---:|"]
    for category, label in CATEGORIES.items():
        row = category_counts[category]
        table.append(f"| {label} | {row['visible']} | {row['fitted_state_exists']} | {row['fallback']} | {row['source_marked_unconverted']} | {row['source_marked_unused']} |")
    document = f"""# Пробелы в одежде воксов

Срез: **{snapshot_date}** (Europe/Kaliningrad). Проверены начальные состояния {len(items)} видимых типов
головных уборов, масок, униформы и обуви после `Initialize()`.
У {summary['fitted_state_exists']} найден видовой state, {summary['fallback']} используют обычный спрайт (fallback).
Это число типов предметов, включая подтипы с одинаковыми изображениями.

{chr(10).join(table)}

Последние два столбца входят в число найденных fitted state. **`fitted=1`
подтверждает существование состояния, а не правильную форму, цвет или слои.**
Fallback сохраняет обычный спрайт предмета; его посадка на воксе требует проверки.

В `uniform.dmi` после маркера `NEEDS CONVERTED >>>>>` лежат
{marker_summary['source_marked_unconverted']['states_after_marker']} состояний; инвентарь использует {marker_summary['source_marked_unconverted']['used_states']} из них для
**{issue_counts['source_marked_unconverted']} типов**. Они отмечены `source_marked_unconverted` отдельно от отсутствующих
видовых спрайтов. Среди примеров — форма охраны (`rsecurity`, `security`),
костюм мима (`mime`), юбки инженера и врача (`engine_skirt`, `medical_skirt`),
цветные костюмы клоуна. Наличие этих изображений не снимает исходную отметку
о незавершённой конвертации.

После `UNUSED >` в `feet.dmi` находятся {marker_summary['source_marked_unused']['states_after_marker']} состояний;
**{issue_counts['source_marked_unused']} используемых типа** отмечены `source_marked_unused`: синдикатские магнитные
ботинки, зимние ботинки, римская обувь и Jack Frost shoes. Этот маркер
не подтверждает готовность и не равнозначен `NEEDS CONVERTED`.

Частые примеры fallback: шапки beanie и ушанки; шарфы-маски
`breathscarf`/`facescarf`; корпоративная форма охраны, часть юбок и одежды
с GAGS; обычные и улучшенные магнитные ботинки, чёрные сандалии.
Из {summary['fallback']} fallback у {reason_counts['unsupported_vox_greyscale_config']} отсутствует подходящая конфигурация GAGS для вокса;
остальные причины указаны построчно.

Ещё {len(inventory['skipped'])} типа исключены из видимой выборки: {summary['skipped_reasons'].get('no_native_initial_worn_state', 0)} без начального worn state,
{summary['skipped_reasons'].get('invisible_native_worn_sprite', 0)} с невидимым обычным спрайтом и {summary['skipped_reasons'].get('transforms_or_deletes_during_Initialize', 0)} изменяющихся/удаляющихся при `Initialize()`.
Их перечень сохранён в JSON. Срез не охватывает все состояния переключения,
все цвета, остальные слоты и все сочетания одежды.

Результаты автотестов и визуальная матрица описаны в
[VOX_VALIDATION.md](VOX_VALIDATION.md). Они не являются художественной
проверкой всех {len(items)} типов и не означают, что перечисленные пробелы устранены.

Полный список **{len(gaps)} записей**: [clothing-gaps.csv](../../tools/vox/clothing-gaps.csv)
({summary['fallback']} fallback + {issue_counts['source_marked_unconverted']} source_marked_unconverted + {issue_counts['source_marked_unused']} source_marked_unused).
Счётчики, причины исключений и хэши: [clothing-gaps-summary.json](../../tools/vox/clothing-gaps-summary.json).

Перегенерация из результата нового прогона:

```powershell
python tools/vox/report_clothing_gaps.py tmp/vox-test-<run>/data/vox-clothing-inventory.json
```
"""
    (ROOT / "modular_bandastation/species/VOX_CLOTHING_GAPS.md").write_text(document, encoding="utf-8")
    print(json.dumps({"visible": len(items), "issues": dict(issue_counts), "reasons": dict(reason_counts), "gap_rows": len(gaps)}, ensure_ascii=False))


if __name__ == "__main__":
    main()
