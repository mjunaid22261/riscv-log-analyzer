#!/bin/bash
# setup_env.sh - Verify required tools exist and prepare the output directory.
set -euo pipefail

cd "$(dirname "$0")/.."        # always run from the repo root

REQUIRED=(bash grep awk sed sort date make git)
missing=0

echo "Checking required tools..."
for tool in "${REQUIRED[@]}"; do
    if command -v "$tool" > /dev/null 2>&1; then
        printf '  [ok]      %s\n' "$tool"
    else
        printf '  [MISSING] %s\n' "$tool"
        missing=$((missing + 1))
    fi
done

mkdir -p output
chmod +x scripts/*.sh

if [ "$missing" -gt 0 ]; then
    echo "$missing tool(s) missing. Install them, for example: sudo apt install <tool>" >&2
    exit 1
fi
echo "Environment ready."

