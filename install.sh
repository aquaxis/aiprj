#!/usr/bin/env bash
set -euo pipefail

REPO="aquaxis/aiprj"
BRANCH="${AIPRJ_BRANCH:-main}"
INSTALL_SHARE="${HOME}/.local/share/aiprj"
INSTALL_BIN="${HOME}/.local/bin"

# Locate source: prefer current directory when it looks like the repo,
# otherwise download a tarball from GitHub (curl one-liner mode).
if [ -f "./aiprj" ] && [ -d "./.aiprj" ] && [ -d "./.claude" ]; then
  SRC_DIR="$(pwd)"
  CLEANUP=""
else
  command -v curl >/dev/null 2>&1 || { echo "curl is required" >&2; exit 1; }
  command -v tar  >/dev/null 2>&1 || { echo "tar is required"  >&2; exit 1; }
  TMP="$(mktemp -d)"
  CLEANUP="$TMP"
  trap 'rm -rf "$CLEANUP"' EXIT
  echo "Downloading ${REPO}@${BRANCH} ..."
  curl -fsSL "https://github.com/${REPO}/archive/refs/heads/${BRANCH}.tar.gz" \
    | tar xz -C "$TMP"
  SRC_DIR="${TMP}/aiprj-${BRANCH}"
fi

# Clean existing install before reinstalling.
if [ -e "$INSTALL_SHARE" ]; then
  echo "Removing existing $INSTALL_SHARE"
  rm -rf "$INSTALL_SHARE"
fi
if [ -e "${INSTALL_BIN}/aiprj" ]; then
  echo "Removing existing ${INSTALL_BIN}/aiprj"
  rm -f "${INSTALL_BIN}/aiprj"
fi

mkdir -p "$INSTALL_SHARE"
mkdir -p "$INSTALL_BIN"

cp -r "${SRC_DIR}/.aiprj"  "${INSTALL_SHARE}/"
cp -r "${SRC_DIR}/.claude" "${INSTALL_SHARE}/"

cp "${SRC_DIR}/.gitignore.aiprj" "${INSTALL_SHARE}/"
cp "${SRC_DIR}/.mcp.json"        "${INSTALL_SHARE}/"

cp "${SRC_DIR}/README.md" "${INSTALL_SHARE}/.aiprj/"

install -m 755 "${SRC_DIR}/aiprj" "${INSTALL_BIN}/aiprj"

echo "Installed: ${INSTALL_BIN}/aiprj"
echo "Assets:    ${INSTALL_SHARE}"
case ":${PATH}:" in
  *":${INSTALL_BIN}:"*) ;;
  *) echo "Note: ${INSTALL_BIN} is not on PATH. Add it to your shell rc." ;;
esac
