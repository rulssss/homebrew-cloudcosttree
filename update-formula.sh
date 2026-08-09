#!/usr/bin/env bash
# Updates Formula/cloudcosttree.rb to point at a new cloudcosttree CLI
# release -- run this manually after cutting a new release in
# rulssss/cloudcosttree (see that repo's release process), then review
# the diff, commit, and push. Deliberately not automated any further
# than this (no auto-publish on a GitHub release event): matches this
# project's existing manual, explicit-confirmation release process.
#
# Usage: ./update-formula.sh v0.1.36
set -euo pipefail

VERSION="${1:?usage: update-formula.sh vX.Y.Z}"
VERSION="${VERSION#v}"
REPO="rulssss/cloudcosttree"
FORMULA="Formula/cloudcosttree.rb"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

sha() {
  local asset="$1"
  curl -fsSL -o "$TMPDIR/$asset" "https://github.com/$REPO/releases/download/v$VERSION/$asset"
  shasum -a 256 "$TMPDIR/$asset" | awk '{print $1}'
}

echo "Fetching assets for v$VERSION..."
DARWIN_ARM64_SHA=$(sha cloudcosttree-darwin-arm64)
DARWIN_AMD64_SHA=$(sha cloudcosttree-darwin-amd64)
LINUX_ARM64_SHA=$(sha cloudcosttree-linux-arm64)
LINUX_AMD64_SHA=$(sha cloudcosttree-linux-amd64)
PRICES_SHA=$(sha prices.json)

cat >"$FORMULA" <<EOF
class Cloudcosttree < Formula
  desc "Estimate AWS infrastructure costs in a hierarchical tree before you apply"
  homepage "https://cloudcosttree.com"
  # version is inferred from the release URL below (redundant to also set it
  # explicitly, per \`brew audit\`). :cannot_represent is Homebrew's own
  # documented way to mark a real, intentional non-SPDX (proprietary)
  # license, not a placeholder for "unknown."
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/$REPO/releases/download/v$VERSION/cloudcosttree-darwin-arm64"
      sha256 "$DARWIN_ARM64_SHA"
    else
      url "https://github.com/$REPO/releases/download/v$VERSION/cloudcosttree-darwin-amd64"
      sha256 "$DARWIN_AMD64_SHA"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/$REPO/releases/download/v$VERSION/cloudcosttree-linux-arm64"
      sha256 "$LINUX_ARM64_SHA"
    else
      url "https://github.com/$REPO/releases/download/v$VERSION/cloudcosttree-linux-amd64"
      sha256 "$LINUX_AMD64_SHA"
    end
  end

  # The bundled price catalog (see the main repo's README: "data/prices.json
  # travels with it, so a plain analyze/tree/diff run needs no AWS account").
  # Installed at bin/data/prices.json, alongside the binary -- DefaultPricesPath
  # (pkg/cost/catalog.go) checks <dir of the running executable>/data/prices.json
  # as its second-priority lookup, and Go's os.Executable() resolves through
  # Homebrew's opt/bin symlink to the real Cellar path, confirmed by testing
  # this exact layout locally before publishing. \`brew audit\` flags this as
  # "non-executable file in bin" -- a deliberate exception, not an oversight:
  # moving prices.json to the "correct" pkgshare location would mean the
  # binary can't find it without a wrapper script or an explicit --prices
  # flag on every invocation, defeating the whole "just works out of the
  # box" point of bundling it. This is a personal tap, not a homebrew-core
  # submission, so this style warning doesn't block anything.
  resource "prices" do
    url "https://github.com/$REPO/releases/download/v$VERSION/prices.json"
    sha256 "$PRICES_SHA"
  end

  def install
    bin.install Dir["cloudcosttree-*"].first => "cloudcosttree"
    resource("prices").stage do
      (bin/"data").install "prices.json"
    end
  end

  test do
    system "#{bin}/cloudcosttree", "--help"
  end
end
EOF

echo "Updated $FORMULA to v$VERSION. Review the diff, then:"
echo "  brew install --build-from-source $FORMULA && brew test rulssss/cloudcosttree/cloudcosttree"
echo "  git commit -am 'cloudcosttree v$VERSION' && git push"
