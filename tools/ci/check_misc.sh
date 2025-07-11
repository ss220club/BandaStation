#!/bin/bash
set -euo pipefail

find . -name "*.json" -not -path "*/node_modules/*" -not -path "*/_work/*" -print0 | xargs -0 python3 ./tools/json_verifier.py
