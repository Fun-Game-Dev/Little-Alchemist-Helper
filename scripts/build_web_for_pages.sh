#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="${REPO_ROOT}/little_alchemist_helper"
DOCS_DIR="${REPO_ROOT}/docs"

REPO_NAME="${1:-$(basename "${REPO_ROOT}")}"
BASE_HREF="/${REPO_NAME}/"

echo "Building Flutter web for GitHub Pages..."
echo "Repository name: ${REPO_NAME}"
echo "Base href: ${BASE_HREF}"

cd "${APP_DIR}"
flutter pub get
flutter build web --release --base-href "${BASE_HREF}"

echo "Publishing build output to docs/ ..."
rm -rf "${DOCS_DIR}"
mkdir -p "${DOCS_DIR}"
cp -R build/web/. "${DOCS_DIR}/"

echo "Done. Commit and push the updated docs/ folder."
