class Cloudcosttree < Formula
  desc "Estimate AWS infrastructure costs in a hierarchical tree before you apply"
  homepage "https://cloudcosttree.com"
  # version is inferred from the release URL below (redundant to also set it
  # explicitly, per `brew audit`). :cannot_represent is Homebrew's own
  # documented way to mark a real, intentional non-SPDX (proprietary)
  # license, not a placeholder for "unknown."
  license :cannot_represent

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.59/cloudcosttree-darwin-arm64"
      sha256 "c92d93736f135f83689a927a3629689f52fc76382eafe444dea23c06f09e6640"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.59/cloudcosttree-darwin-amd64"
      sha256 "04456d1eda65ee17289fff4b1be9d4bd3fa5f4efa0b006266a3343b84cd29223"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.59/cloudcosttree-linux-arm64"
      sha256 "5ec00ba251353b5dcb0598869ff52e52bde4cac59d0a6642dfad8dbb4e83c9ea"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.59/cloudcosttree-linux-amd64"
      sha256 "aae8a9cc08489e24423f64d4efbb9036788d465783b6fe749eaebf2929baf95b"
    end
  end

  # The bundled price catalog (see the main repo's README: "data/prices.json
  # travels with it, so a plain analyze/tree/diff run needs no AWS account").
  # Installed at bin/data/prices.json, alongside the binary -- DefaultPricesPath
  # (pkg/cost/catalog.go) checks <dir of the running executable>/data/prices.json
  # as its second-priority lookup, and Go's os.Executable() resolves through
  # Homebrew's opt/bin symlink to the real Cellar path, confirmed by testing
  # this exact layout locally before publishing. `brew audit` flags this as
  # "non-executable file in bin" -- a deliberate exception, not an oversight:
  # moving prices.json to the "correct" pkgshare location would mean the
  # binary can't find it without a wrapper script or an explicit --prices
  # flag on every invocation, defeating the whole "just works out of the
  # box" point of bundling it. This is a personal tap, not a homebrew-core
  # submission, so this style warning doesn't block anything.
  resource "prices" do
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.59/prices.json"
    sha256 "1e21372d8b6dc5ad654baa54e7de8d6ff8d4d7ba21464f40a83a0732ef12aec0"
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
