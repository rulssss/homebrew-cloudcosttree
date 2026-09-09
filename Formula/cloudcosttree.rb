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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.24/cloudcosttree-darwin-arm64"
      sha256 "888834e7c836e8fde9c9ceae1ae4211934f2fb9d6a8583b399dc449cee61272e"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.24/cloudcosttree-darwin-amd64"
      sha256 "72d8f59453689f98b4604592f3ccdaceee4293889b89b716512345fa86edc4f8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.24/cloudcosttree-linux-arm64"
      sha256 "c690571e4b6049382a67266b18aa822add6421ff9c735a4e561c65941d0ce537"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.24/cloudcosttree-linux-amd64"
      sha256 "f6f926b425b3d62c738e9c5c7b23d72f9ea445327061208e8c14bfada4cb97ae"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.24/prices.json"
    sha256 "7ed50ff12c37fc13b4aec7baed4e303beccf1dbed595770fa6d593d24ab8d88c"
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
