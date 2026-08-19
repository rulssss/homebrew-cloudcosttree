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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.57/cloudcosttree-darwin-arm64"
      sha256 "eeea61aba4f469056dba4bd540926cbaa66626724972c93274a1f63e4cf91bd6"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.57/cloudcosttree-darwin-amd64"
      sha256 "8b523be0d4f504163606c0e6a15be57afcbd3a666f406e23f2578a8705c1bb9f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.57/cloudcosttree-linux-arm64"
      sha256 "f2cd241f0f530c19038f3a98481efdf7c1de149303782e3f44e2ae03564ce397"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.57/cloudcosttree-linux-amd64"
      sha256 "0d578085dcae6c64a7dda7d2fea54bbc62d227cec139c38f750a6004188a9a3d"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.57/prices.json"
    sha256 "53ae88d481f2f18c7aa874ecfac76c42efeca1913c0c3b3c84ec4808fb81282b"
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
