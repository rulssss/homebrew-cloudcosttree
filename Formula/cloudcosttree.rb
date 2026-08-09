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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.35/cloudcosttree-darwin-arm64"
      sha256 "ea46c3b215060cc9a8189b2baca78af17c098b2168df1616b8a1eb1ce56664df"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.35/cloudcosttree-darwin-amd64"
      sha256 "62ccba43d933c8df96930e05f8adae719667d0675a685c7bef502df7f29ea34b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.35/cloudcosttree-linux-arm64"
      sha256 "10a25bc21a7e1032a30a1a6789a819bc17e3dbfa1046f051ab8b3db49f64fb2a"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.35/cloudcosttree-linux-amd64"
      sha256 "13e56e931573d38320e77a1cf56d071bd8dfabc44961a3922d5551a9ece65de4"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.35/prices.json"
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
