#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env.release"

CLI_RELEASE_VERSION="${RELEASE_VERSION-}"
CLI_RELEASE_BUILD_NUMBER="${RELEASE_BUILD_NUMBER-}"

# Optional shared env file for another session.
if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  set -a
  source "${ENV_FILE}"
  set +a
fi

# Required environment variables:
# - APP_STORE_CONNECT_KEY_ID
# - APP_STORE_CONNECT_ISSUER_ID
# - APP_STORE_CONNECT_KEY_FILE (path to AuthKey_*.p8)

: "${APP_STORE_CONNECT_KEY_ID:?Set APP_STORE_CONNECT_KEY_ID (Key ID from App Store Connect API key)}"
: "${APP_STORE_CONNECT_ISSUER_ID:?Set APP_STORE_CONNECT_ISSUER_ID}"
: "${APP_STORE_CONNECT_KEY_FILE:?Set APP_STORE_CONNECT_KEY_FILE to AuthKey_*.p8 path}"

if [[ ! -f "${APP_STORE_CONNECT_KEY_FILE}" ]]; then
  echo "APP_STORE_CONNECT_KEY_FILE does not exist: ${APP_STORE_CONNECT_KEY_FILE}"
  exit 1
fi

cd "$ROOT_DIR"

VERSION="${CLI_RELEASE_VERSION:-${RELEASE_VERSION:-1.0.1}}"
BUILD_NUMBER="${CLI_RELEASE_BUILD_NUMBER:-${RELEASE_BUILD_NUMBER:-3}}"

if [[ ! "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid RELEASE_VERSION: ${VERSION} (expected X.Y.Z)"
  exit 1
fi

if ! [[ "${BUILD_NUMBER}" =~ ^[0-9]+$ ]]; then
  echo "Invalid RELEASE_BUILD_NUMBER: ${BUILD_NUMBER} (expected integer)"
  exit 1
fi

export APP_STORE_CONNECT_KEY_ID
export APP_STORE_CONNECT_ISSUER_ID
export APP_STORE_CONNECT_KEY_FILE

if ! command -v fastlane >/dev/null; then
  echo "fastlane is not installed. Install with: brew install fastlane"
  exit 1
fi

echo "Running flutter pub get for generated xcconfig..."
flutter pub get

run_fastlane() {
  if command -v bundle >/dev/null; then
    if bundle exec fastlane --version >/dev/null 2>&1; then
      bundle exec fastlane ios release "$@"
      return
    fi
  fi

  fastlane ios release "$@"
}

echo "Installing iOS pods..."
if ! (cd ios && COCOAPODS_DISABLE_STATS=true pod install --repo-update); then
  echo "Pod repo update failed (likely offline CDN). Falling back to local pod install."
  (cd ios && COCOAPODS_DISABLE_STATS=true pod install)
fi

echo "Running Fastlane iOS release lane..."
run_fastlane "version:$VERSION" "build_number:$BUILD_NUMBER"

echo "Release command completed. Check App Store Connect for processing state."
