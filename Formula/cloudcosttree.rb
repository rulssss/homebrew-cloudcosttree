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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.65/cloudcosttree-darwin-arm64"
      sha256 "f0346291d853e63e520f269ac7f15739924408a86cc0501b25533677b4572522"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.65/cloudcosttree-darwin-amd64"
      sha256 "822e65dd2afb344654feec328f9a4cb424296c3ad936da5bf407ccf541b23ca0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.65/cloudcosttree-linux-arm64"
      sha256 "e071f846b13124420fe4239dc7f687ecfedaf63919287df7f9bac33760ae53e8"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.65/cloudcosttree-linux-amd64"
      sha256 "058611c2f48efdad98574aaba623c71f394702c4b1e28684174e6dbff853a278"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.65/prices.json"
    sha256 "d3d9d14789d870b51659f1124c1a5c5331cf8bf88fb6434207186f7cd85b29c5"
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
