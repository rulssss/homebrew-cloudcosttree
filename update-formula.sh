#!/usr/bin/env bash
# Updates Formula/cloudcosttree.rb to point at a new cloudcosttree CLI
# release -- run this manually after cutting a new release in
# rulssss/cloudcosttree (see that repo's release process), then review
# the diff, commit, and push. Deliberately not automated any further
# than this (no auto-publish on a GitHub release event): matches this
# project's existing manual, explicit-confirmation release process.
#
# The formula body itself lives in cloudcosttree.rb.tmpl (plain Ruby, no
# shell interpolation) -- this script only fills in @TOKEN@ placeholders via
# sed. Earlier versions generated Formula/cloudcosttree.rb from a bash
# heredoc containing the Ruby directly; Homebrew's `brew style` runs a
# bash-only reformatter (shfmt) over every line of this file, including
# heredoc bodies, and it misreads the formula's `if Hardware::CPU.arm?` as
# an unclosed bash if-statement -- a real, reproducible false positive
# (see the tap's git history: 945c9f1/ba3dd5b tried and reverted a ternary
# workaround that fixed shfmt but broke `brew audit`'s ComponentsOrder
# check instead). Keeping the Ruby out of this .sh file entirely sidesteps
# the false positive at its source instead of working around it.
#
# Usage: ./update-formula.sh v0.1.36
set -euo pipefail

VERSION="${1:?usage: update-formula.sh vX.Y.Z}"
VERSION="${VERSION#v}"
REPO="rulssss/cloudcosttree"
TEMPLATE="cloudcosttree.rb.tmpl"
FORMULA="Formula/cloudcosttree.rb"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

sha() {
  local asset="$1"
  curl -fsSL -o "${TMPDIR}/${asset}" "https://github.com/${REPO}/releases/download/v${VERSION}/${asset}"
  shasum -a 256 "${TMPDIR}/${asset}" | awk '{print $1}'
}

echo "Fetching assets for v${VERSION}..."
DARWIN_ARM64_SHA=$(sha cloudcosttree-darwin-arm64)
DARWIN_AMD64_SHA=$(sha cloudcosttree-darwin-amd64)
LINUX_ARM64_SHA=$(sha cloudcosttree-linux-arm64)
LINUX_AMD64_SHA=$(sha cloudcosttree-linux-amd64)
PRICES_SHA=$(sha prices.json)

# "|" as the sed delimiter since the substituted URLs contain "/".
sed \
  -e "s|@REPO@|${REPO}|g" \
  -e "s|@VERSION@|${VERSION}|g" \
  -e "s|@DARWIN_ARM64_SHA@|${DARWIN_ARM64_SHA}|g" \
  -e "s|@DARWIN_AMD64_SHA@|${DARWIN_AMD64_SHA}|g" \
  -e "s|@LINUX_ARM64_SHA@|${LINUX_ARM64_SHA}|g" \
  -e "s|@LINUX_AMD64_SHA@|${LINUX_AMD64_SHA}|g" \
  -e "s|@PRICES_SHA@|${PRICES_SHA}|g" \
  "${TEMPLATE}" >"${FORMULA}"

echo "Updated ${FORMULA} to v${VERSION}. Review the diff, then:"
echo "  brew install --build-from-source ${FORMULA} && brew test rulssss/cloudcosttree/cloudcosttree"
echo "  git commit -am 'cloudcosttree v${VERSION}' && git push"
