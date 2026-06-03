#!/bin/bash
# build-signed-repo.sh — Build hello-go, sign it, create signed pacman repo
#
# Usage:
#   export GPGKEY=<fingerprint>          # optional, auto-detected otherwise
#   ./scripts/build-signed-repo.sh
#
# Requires:
#   - go, base-devel, pacman-contrib (for repo-add)
#   - GPG secret key (sieveeditor@lenucksi.github.io or configured via GPGKEY)
#
# Output:
#   ./repo/go-hello-world/x86_64/   ← signed pacman repo ready for gh-pages

set -euo pipefail

REPO_NAME="go-hello-world"
REPO_DIR="repo/${REPO_NAME}/x86_64"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# --- 1. Find GPG key ------------------------------------------------
GPGKEY="${GPGKEY:-}"
if [ -z "$GPGKEY" ]; then
  GPGKEY=$(gpg --list-secret-keys --with-colons sieveeditor@lenucksi.github.io 2>/dev/null \
    | grep '^sec' | head -1 | cut -d: -f5)
fi
if [ -z "$GPGKEY" ]; then
  GPGKEY=$(gpg --list-secret-keys --with-colons 2>/dev/null \
    | grep '^sec' | head -1 | cut -d: -f5)
fi
if [ -z "$GPGKEY" ]; then
  echo "ERROR: No GPG secret key found."
  echo "  Import one:  gpg --import private.asc"
  echo "  Or set:      export GPGKEY=<fingerprint>"
  exit 1
fi
echo "=== Using GPG key: ${GPGKEY} ==="

# --- 2. Build + sign Arch package -----------------------------------
cd "${SCRIPT_DIR}/hello-go"
echo "=== Building hello-go package ==="
makepkg --clean --force --noconfirm --sign --key "${GPGKEY}"

# --- 3. Create repo structure ---------------------------------------
echo "=== Creating signed repo at ${REPO_DIR} ==="
mkdir -p "${SCRIPT_DIR}/${REPO_DIR}"

# Copy package + signature
cp hello-go-*.pkg.tar.zst "${SCRIPT_DIR}/${REPO_DIR}/"
cp hello-go-*.pkg.tar.zst.sig "${SCRIPT_DIR}/${REPO_DIR}/"

# Copy public key
cp "${SCRIPT_DIR}/public.asc" "${SCRIPT_DIR}/${REPO_DIR}/"

# --- 4. Create signed repo database ---------------------------------
cd "${SCRIPT_DIR}/${REPO_DIR}"
repo-add --sign --verify --include-sigs --key "${GPGKEY}" \
  "${REPO_NAME}.db.tar.zst" hello-go-*.pkg.tar.zst

# Symlinks for pacman compatibility
ln -sf "${REPO_NAME}.db.tar.zst" "${REPO_NAME}.db"
ln -sf "${REPO_NAME}.files.tar.zst" "${REPO_NAME}.files"

# --- 5. Verify ------------------------------------------------------
echo "=== Verifying package signatures ==="
for pkg in hello-go-*.pkg.tar.zst; do
  gpg --verify "${pkg}.sig" "${pkg}"
done

echo "=== Verifying repo database signature ==="
gpg --verify "${REPO_NAME}.db.tar.zst.sig" "${REPO_NAME}.db.tar.zst"

# --- 6. Cleanup -----------------------------------------------------
cd "${SCRIPT_DIR}/hello-go"
rm -f hello-go-*.pkg.tar.zst hello-go-*.pkg.tar.zst.sig

echo ""
echo "============================================"
echo "  Signed repo ready: ${REPO_DIR}"
echo "============================================"
echo ""
echo "To use this repo in Arch Linux, add to /etc/pacman.conf:"
echo ""
echo "  [go-hello-world]"
echo "  SigLevel = Required DatabaseOptional"
echo "  Server = file://${SCRIPT_DIR}/repo/${REPO_NAME}"
echo ""
echo "Then:"
echo "  sudo pacman -Sy               # refresh repos"
echo "  sudo pacman -S hello-go       # install the package"
echo ""
echo "To verify with GPG:"
echo "  pacman-key --recv-key ${GPGKEY}"
echo "  curl -O https://selinux.lenucksi.github.io/go-hello-world/x86_64/public.asc"
echo "  pacman-key --add public.asc"
echo "  pacman-key --lsign-key ${GPGKEY}"
echo ""
