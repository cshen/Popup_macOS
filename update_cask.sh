#!/usr/bin/env bash
# Usage: ./update_cask.sh <version> <git_commit> <sha256>
# Example: ./update_cask.sh 1.1 abc123def456 abcdef1234567890...
set -euo pipefail




CASK_FILE="$(dirname "$0")/Casks/popup.rb"

# if [[ $# -ne 3 ]]; then
#  echo "Usage: $0 <version> <git_commit> <sha256>"
#  echo ""
#  echo "  version     App version number (e.g. 1.1)"
#  echo "  git_commit  Full git commit SHA of the release (e.g. 3fade0d2dd3f...)"
#  echo "  sha256      SHA-256 checksum of Popup.dmg"
#  echo ""
#  echo "To get the sha256, run:"
#  echo "  shasum -a 256 Popup.dmg"
#  exit 1
# fi

# VERSION="$1"
# COMMIT="$2"
# SHA256="$3"

VERSION="v1.0.2"
COMMIT=`git rev-parse $VERSION`
SHA256=`shasum -a 256 Popup.dmg | awk '{print $1}'`


# Update version (format: "X.Y,<commit>")
sed -i '' "s/^  version \".*\"/  version \"${VERSION},${COMMIT}\"/" "$CASK_FILE"

# Update sha256
sed -i '' "s/^  sha256 \".*\"/  sha256 \"${SHA256}\"/" "$CASK_FILE"

echo "Updated $CASK_FILE:"
echo "  version: ${VERSION},${COMMIT}"
echo "  sha256:  ${SHA256}"
