#!/usr/bin/env bash
set -euo pipefail
echo "[*] Rebuilding ST-03 image..."
docker compose build st03-web
echo "[*] Recreating ST-03 container (fresh DB on boot)..."
docker compose up -d --force-recreate --no-deps st03-web
echo "[*] Done. ST-03 is back to a clean state."
