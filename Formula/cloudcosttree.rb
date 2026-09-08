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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.20/cloudcosttree-darwin-arm64"
      sha256 "860abdee8fec9963d38b12337b297f92dd2955cd315c43797c60c65f86554669"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.20/cloudcosttree-darwin-amd64"
      sha256 "79c254fbcf50b934ea5c8c5082937fe17a9ade9122d10c3f68c43f70ec6abb53"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.20/cloudcosttree-linux-arm64"
      sha256 "950a24095de3624e45aaedb4caadc2b63d8936a67cbacbdbb81c67fc00743dc5"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.20/cloudcosttree-linux-amd64"
      sha256 "55e7d9e0acea1fce8dbdc57c59fe99353f0cc852e1f94c50c7fe8efa2db4967e"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.20/prices.json"
    sha256 "b00da62c100a6ae97eb3b664e7664cc534b20262a084e4d5b68623c5f7ab7483"
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
