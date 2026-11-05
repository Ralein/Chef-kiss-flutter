#!/usr/bin/env bash
# Downloads the SQLite WebAssembly build and Drift web worker that the web
# target needs (lib/data/db/connection/connection_web.dart loads
# web/sqlite3.wasm and web/drift_worker.js). Versions are read from
# pubspec.lock so they always match the Dart packages in use.
set -euo pipefail
cd "$(dirname "$0")/.."

locked_version() {
  awk -v pkg="  $1:" '$0==pkg {f=1} f && /version:/ {gsub(/"/, "", $2); print $2; exit}' pubspec.lock
}

SQLITE3_VERSION="$(locked_version sqlite3)"
DRIFT_VERSION="$(locked_version drift)"
echo "sqlite3 ${SQLITE3_VERSION}, drift ${DRIFT_VERSION}"

curl -fL --retry 3 -o web/sqlite3.wasm \
  "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-${SQLITE3_VERSION}/sqlite3.wasm"
curl -fL --retry 3 -o web/drift_worker.js \
  "https://github.com/simolus3/drift/releases/download/drift-${DRIFT_VERSION}/drift_worker.js"

echo "Done: web/sqlite3.wasm and web/drift_worker.js"
