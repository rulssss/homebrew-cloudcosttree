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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.37/cloudcosttree-darwin-arm64"
      sha256 "195f13a1a416a069406b1224202168105b472b97b514ed14e939dce9d7b02646"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.37/cloudcosttree-darwin-amd64"
      sha256 "aa119c5c871e04dccfef8ff631d20087f022230a39bf6fef4b1aa10f02721c99"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.37/cloudcosttree-linux-arm64"
      sha256 "17bd7dacb67b8d17659ffdc9df20ba9cc0dc3d3b94921b1273659fc22a2a681f"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.37/cloudcosttree-linux-amd64"
      sha256 "587acf1dcb600b1a7a2ab72446416c2fadfb1642a69cc1796a0ebe55ac530db3"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.37/prices.json"
    sha256 "be41c71d7800bd2b12e0ded79b26265900140fa2e974f3505940cf967ec50c86"
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
