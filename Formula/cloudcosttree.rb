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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.60/cloudcosttree-darwin-arm64"
      sha256 "ad8d8cd0d8625acb17a15b2788f8c45a33705a2a69f57a8be60e1f738138a257"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.60/cloudcosttree-darwin-amd64"
      sha256 "ef36da7db630633e6cc70fc0e3bb37a1e2eb264dd35ce5b2995480a2e8df6b72"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.60/cloudcosttree-linux-arm64"
      sha256 "bdd42c1577b7a41cfef1864304e65161a105b00d83e229d837ca7db43b70a047"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.60/cloudcosttree-linux-amd64"
      sha256 "25b301c700b4d7ac3525e1079442275e432843daf564b25701801b11b76dfa96"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.60/prices.json"
    sha256 "58c6493f5029ffcb3202eae5646b59ca9a6e5b9640ee887fe61385f0d0d599d9"
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
