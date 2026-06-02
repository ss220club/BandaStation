import sys
import tomllib
from pathlib import Path

from jsonschema import validate
from jsonschema.exceptions import ValidationError

STR = {"type": "string", "minLength": 1}
ENTRY = {
    "type": "object",
    "properties": {
        "nominative": STR,
        "genitive": STR,
        "dative": STR,
        "accusative": STR,
        "instrumental": STR,
        "prepositional": STR,
        "gender": {"type": "string", "enum": ["male", "female", "neuter", "plural"]},
    },
    "required": ["nominative"],
    "additionalProperties": False,
}

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(f"usage: {sys.argv[0]} <bundle.toml>")
    path = Path(sys.argv[1])
    try:
        text = path.read_text(encoding="utf-8")
        for n, line in enumerate(text.splitlines(), 1):
            s = line.strip()
            if s.startswith("[") and s.endswith("]") and not s[1:-1].strip().startswith('"'):
                print(f"{path}:{n}: object key must be in double quotes: {s[1:-1].strip()!r}", file=sys.stderr)
                sys.exit(1)
        validate(tomllib.loads(text), {"type": "object", "additionalProperties": ENTRY})
    except (tomllib.TOMLDecodeError, ValidationError) as err:
        print(err, file=sys.stderr)
        sys.exit(1)
