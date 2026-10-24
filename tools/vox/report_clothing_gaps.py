"""Rebuild clothing gaps from the expanded Vox runtime audit and pinned donor map."""
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
PARADISE = "icons/bandastation/mob/species/vox/paradise/"
MARKERS = {
    ASSETS + "uniform.dmi": ("NEEDS CONVERTED >>>>>", "source_marked_unconverted"),
    ASSETS + "feet.dmi": ("UNUSED >", "source_marked_unused"),
}
CATEGORIES = {
    "head": "Головные уборы", "mask": "Маски", "under": "Униформа", "shoes": "Обувь",
    "suit": "Верхняя одежда", "eyes": "Очки", "ears": "Гарнитуры", "gloves": "Перчатки",
    "neck": "Шея", "back": "Рюкзаки", "belt": "Пояса", "mod_control": "Блоки MOD",
}
REASONS = {
    "unsupported_vox_greyscale_config": "нет совместимой конфигурации GAGS для вокса",
    "missing_state_in_supported_vox_greyscale": "в поддерживаемом GAGS нет нужного состояния",
    "no_selected_vox_worn_state": "не найден подходящий видовой worn state",
    "source_marked_unconverted": "выбран исходный state после NEEDS CONVERTED",
    "source_marked_unused": "выбран исходный state после UNUSED",
}
EXCLUSION_REASONS_RU = {
    "Rejected: the donor armour draws a Paradise-shaped tail cover, while this TG item does not hide the current Vox tail; east/west views show two tails.":
        "На видах сбоку появляется второй хвост: он уже нарисован в броне Paradise, а предмет TG не скрывает хвост вокса.",
}
FIELDS = (
    "name_ru", "type", "state", "category", "issue", "reason", "fitted",
    "fitted_icon", "native_icon", "greyscale_config", "source_marker", "paradise_exclusion",
    "source_repository", "source_revision", "source_file", "source_state", "source_blob",
)


def load_donor(mapping_path, provenance_path, art_review_path):
    mapping = json.loads(mapping_path.read_text(encoding="utf-8"))
    provenance = json.loads(provenance_path.read_text(encoding="utf-8"))
    if mapping["source_revision"] != provenance["revision"]:
        raise ValueError("Clothing map and donor provenance have different revisions.")
    indexed, target_keys = {}, set()
    for entry in mapping["entries"]:
        key = (entry["category"], entry["target_state"])
        if key in target_keys:
            raise ValueError(f"Duplicate donor target: {key}")
        target_keys.add(key)
        if entry["source_file"] not in provenance["assets"]:
            raise ValueError(f"Unpinned donor source: {entry['source_file']}")
        if entry["mode"] not in {"missing_only", "reviewed_replacement"}:
            raise ValueError(f"Unknown donor mapping mode: {entry['mode']}")
        suffix = "_replacement" if entry["mode"] == "reviewed_replacement" else ""
        indexed[(f"{PARADISE}{entry['category']}{suffix}.dmi", entry["target_state"])] = entry
    reviewed, review = set(), {}
    if art_review_path:
        review = json.loads(art_review_path.read_text(encoding="utf-8"))
        if review["source_revision"] != mapping["source_revision"] or not review.get("evidence"):
            raise ValueError("Art review must match the donor revision and identify visual evidence.")
        if review.get("mapping_sha256") != hashlib.sha256(mapping_path.read_bytes()).hexdigest():
            raise ValueError("Art review does not match the current clothing map recipe.")
        for entry in review["reviewed_entries"]:
            key = (entry["category"], entry["state"])
            if key not in target_keys or key in reviewed:
                raise ValueError(f"Unknown or duplicate art-review target: {key}")
            reviewed.add(key)
    exclusions = collections.defaultdict(list)
    for entry in mapping.get("exclusions", []):
        if not entry.get("reason"):
            raise ValueError("Every explicit donor exclusion needs a reason.")
        category = "head" if entry["category"] == "helmet" else entry["category"]
        exclusions[(category, entry["target_state"])].append(entry)
    return mapping, provenance, indexed, reviewed, review, exclusions


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("inventory", type=Path, help="data/vox-clothing-inventory.json from test-vox.ps1")
    parser.add_argument("--art-review", type=Path, help="Explicit reviewed_entries; rendering alone is not an art review")
    args = parser.parse_args()
    snapshot_date = datetime.fromtimestamp(
        args.inventory.stat().st_mtime, timezone(timedelta(hours=2)),
    ).date().isoformat()
    inventory = json.loads(args.inventory.read_text(encoding="utf-8"))
    items = inventory["items"]
    if len({item["type"] for item in items}) != len(items):
        raise ValueError("The runtime inventory contains duplicate item types.")
    categories = {item["category"] for item in items}
    if categories != set(CATEGORIES):
        raise ValueError(f"Use the expanded twelve-category audit. Missing: {sorted(set(CATEGORIES) - categories)}; unknown: {sorted(categories - set(CATEGORIES))}")
    output_dir = Path(__file__).resolve().parent
    mapping_path = output_dir / "paradise-clothing-map.json"
    provenance_path = output_dir / "paradise-source-assets.json"
    mapping, provenance, donor_index, reviewed, art_review, exclusions = load_donor(mapping_path, provenance_path, args.art_review)

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
    selected_entries = set()
    for category in CATEGORIES:
        rows = [item for item in items if item["category"] == category]
        category_counts[category] = {
            "visible": len(rows), "fitted_state_exists": sum(bool(item["fitted"]) for item in rows),
            "fallback": sum(not item["fitted"] for item in rows),
            "source_marked_unconverted": 0, "source_marked_unused": 0,
            "paradise_selected_types": 0, "paradise_art_reviewed_types": 0,
        }
    for item in items:
        marker = ""
        entry = donor_index.get((item.get("fitted_icon"), item["state"]))
        fitted_icon = item.get("fitted_icon") or ""
        if fitted_icon.startswith(PARADISE) and not entry:
            raise ValueError(f"Selected donor state is absent from the map: {item['type']}")
        if entry:
            key = (entry["category"], entry["target_state"])
            selected_entries.add(key)
            category_counts[item["category"]]["paradise_selected_types"] += 1
            category_counts[item["category"]]["paradise_art_reviewed_types"] += key in reviewed
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
        excluded = exclusions.get((item["category"], item["state"]), [])
        source_entry = entry or (excluded[0] if len(excluded) == 1 else None)
        gaps.append({
            **{field: item.get(field, "") for field in FIELDS},
            "name_ru": item.get("name_ru") or item["name"],
            "issue": issue, "reason": reason, "source_marker": marker,
            "paradise_exclusion": " | ".join(row["reason"] for row in excluded),
            "source_repository": provenance["repository"] if source_entry else "",
            "source_revision": provenance["revision"] if source_entry else "",
            "source_file": source_entry.get("source_file", "") if source_entry else "",
            "source_state": source_entry.get("source_state", "") if source_entry else "",
            "source_blob": provenance["assets"].get(source_entry.get("source_file"), "") if source_entry else "",
        })
    gaps.sort(key=lambda item: (item["category"], item["issue"], item["type"]))
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
        "paradise": {
            "repository": provenance["repository"], "source_revision": provenance["revision"],
            "license": provenance["license"],
            "mapping_sha256": hashlib.sha256(mapping_path.read_bytes()).hexdigest(),
            "provenance_sha256": hashlib.sha256(provenance_path.read_bytes()).hexdigest(),
            "mapped_states": len(mapping["entries"]),
            "mapped_states_by_category": dict(collections.Counter(row["category"] for row in mapping["entries"])),
            "art_reviewed_states": len(reviewed),
            "art_review_sha256": hashlib.sha256(args.art_review.read_bytes()).hexdigest() if args.art_review else None,
            "art_review_evidence": art_review.get("evidence", ""),
            "initial_selected_states": len(selected_entries),
            "initial_selected_types": sum(row["paradise_selected_types"] for row in category_counts.values()),
            "initial_art_reviewed_types": sum(row["paradise_art_reviewed_types"] for row in category_counts.values()),
            "excluded_states": len(mapping.get("exclusions", [])), "exclusions": mapping.get("exclusions", []),
            "policy_exclusions": mapping.get("policy", {}).get("exclusions", []),
            "source_assets": provenance["assets"],
        },
    }
    (output_dir / "clothing-gaps-summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n",
    )
    table = ["| Категория | Видимых типов | Видовой state есть | Fallback | NEEDS CONVERTED | UNUSED | Paradise | Paradise просмотрен |",
             "|---|---:|---:|---:|---:|---:|---:|---:|"]
    for category, label in CATEGORIES.items():
        row = category_counts[category]
        table.append(f"| {label} | {row['visible']} | {row['fitted_state_exists']} | {row['fallback']} | {row['source_marked_unconverted']} | {row['source_marked_unused']} | {row['paradise_selected_types']} | {row['paradise_art_reviewed_types']} |")
    donor = summary["paradise"]
    excluded_lines = [
        f"- `{entry['test_type']}` / `{entry['target_state']}` — {EXCLUSION_REASONS_RU.get(entry['reason'], entry['reason'])}"
        for entry in donor["exclusions"]
    ] or ["В карте переноса нет явно исключённых состояний."]
    remaining_lines = []
    for reason, count in sorted(reason_counts.items()):
        examples = []
        for item in gaps:
            if item["reason"] != reason or item["paradise_exclusion"]:
                continue
            example = f"{item['name_ru']} (`{item['state']}`)"
            if example not in examples:
                examples.append(example)
            if len(examples) == 3:
                break
        remaining_lines.append(f"- {REASONS[reason]}: **{count}**."
                               + (" Примеры: " + "; ".join(examples) + "." if examples else ""))
    review_note = (f"Доказательство просмотра: {donor['art_review_evidence']}"
                   if donor["art_review_evidence"] else "Результат отдельного художественного просмотра не передан генератору.")
    document = f"""# Пробелы в одежде воксов

Срез: **{snapshot_date}** (Europe/Kaliningrad). Проверены начальные worn states
**{len(items)} видимых типов** после `Initialize()` во всех {len(CATEGORIES)} категориях.
У {summary['fitted_state_exists']} типов найден видовой state, {summary['fallback']} используют обычный спрайт (fallback).
Это типы предметов, включая подтипы с одинаковыми изображениями; новых вещей для вокса не создаётся.

{chr(10).join(table)}

**Наличие state не доказывает правильную форму, цвет или слои.** Столбец «Paradise просмотрен»
учитывает только явные записи художественного просмотра, а не прохождение теста или название режима `reviewed_replacement`.
Последние два столбца входят в число существующих видовых states. Маркеры NEEDS CONVERTED и UNUSED учитываются
только когда выбран старый помеченный файл; заменённые Paradise состояния повторно не считаются пробелами.

Из Paradise `{donor['source_revision'][:12]}` подключено **{donor['mapped_states']} состояний**
(включая переключаемые варианты), художественно просмотрено **{donor['art_reviewed_states']}**.
В начальном runtime-срезе выбраны {donor['initial_selected_states']} разных импортированных состояний
для {donor['initial_selected_types']} типов; типов с подтверждённым художественным просмотром: {donor['initial_art_reviewed_types']}.
{review_note}
Записи просмотра: [paradise-art-review.json](../../tools/vox/paradise-art-review.json).

## Что не перенесено

Явно отклонённые состояния из карты переноса ({donor['excluded_states']}):

{chr(10).join(excluded_lines)}

Маски Paradise не подключены: их посадка отличается от текущего клюва; используются имеющиеся маски Nova.
Готовые цветные картинки не заменяют неподдержанные GAGS-семейства, чтобы сохранить выбранный цвет.

Оставшиеся реальные пробелы текущей сборки ({len(gaps)} типов, включая явно отклонённые,
если они попали в начальную выборку):

{chr(10).join(remaining_lines) or 'В начальной выборке пробелов не обнаружено.'}

Причины указаны без предположения, что одноимённая картинка из другого файла подходит этой вещи.
Fallback сохраняет обычный спрайт; его посадка на воксе не подтверждена этим отчётом.
Дополнительно исключённых из видимой выборки типов: {len(inventory['skipped'])}; причины и полный перечень сохранены в JSON.

Полный построчный список: [clothing-gaps.csv](../../tools/vox/clothing-gaps.csv).
Счётчики, исходные blob-хэши, конкретные исключения и границы проверки:
[clothing-gaps-summary.json](../../tools/vox/clothing-gaps-summary.json).
Этот срез не охватывает все переключения, цвета и сочетания одежды. Результаты native-тестов и визуальная матрица
описаны отдельно в [VOX_VALIDATION.md](VOX_VALIDATION.md).

Перегенерация из результата нового прогона:

```powershell
python tools/vox/report_clothing_gaps.py tmp/vox-test-<run>/data/vox-clothing-inventory.json --art-review tools/vox/paradise-art-review.json
```
"""
    (ROOT / "modular_bandastation/species/VOX_CLOTHING_GAPS.md").write_text(document, encoding="utf-8", newline="\n")
    print(json.dumps({"visible": len(items), "issues": dict(issue_counts), "reasons": dict(reason_counts),
                      "gap_rows": len(gaps), "paradise_selected_types": donor["initial_selected_types"],
                      "art_reviewed_states": len(reviewed)}, ensure_ascii=False))


if __name__ == "__main__":
    main()
