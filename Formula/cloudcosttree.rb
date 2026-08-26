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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.7/cloudcosttree-darwin-arm64"
      sha256 "8be642c29ad7ff2d01ceff7960460116cf4aaf145ac6ef47df6de920193d512d"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.7/cloudcosttree-darwin-amd64"
      sha256 "e7a6a0ce992b3aebda54a26107e359be76d725d8d1bd470a622d11beb25b9b9f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.7/cloudcosttree-linux-arm64"
      sha256 "6a769e4bd54afd3a0c34134084cd018c295af37ddf8f575731e7b72a08cc2f3c"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.7/cloudcosttree-linux-amd64"
      sha256 "e924cfc1ebc5f56a7c44b1f775befbc34056a01d51205793c30579901188f431"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.7/prices.json"
    sha256 "8dfee9802980a3bb5eada583bd359688d6420f9e871c812b0de73d9ff341a70b"
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
