#!/usr/bin/env bash
# Recreates the ST-06 container from a clean image.
# Matches the report's reset mechanism: "Recreate container/restore VM snapshot".
set -euo pipefail

echo "[*] Rebuilding ST-06 image..."
docker compose build st06-linux

echo "[*] Recreating ST-06 container (fresh flag + permissions on boot)..."
docker compose up -d --force-recreate --no-deps st06-linux

echo "[*] Done. ST-06 is back to a clean state."
