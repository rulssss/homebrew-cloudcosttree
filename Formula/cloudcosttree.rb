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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.67/cloudcosttree-darwin-arm64"
      sha256 "b982967cedb78217eb6b860eff21151c816f579430a0969fd36bac7daac640ad"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.67/cloudcosttree-darwin-amd64"
      sha256 "2d7a4760cfd97d1e00d51b973a297746c8867c10f3c3e3727d46a5fb5889861f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.67/cloudcosttree-linux-arm64"
      sha256 "89a6e609fcab295cb7be25c553ab4b5d6df08f0999e30288beb2b1091b378e9e"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.67/cloudcosttree-linux-amd64"
      sha256 "fd869fb9e3d43a76401acc5df32aa0a30f5ee8d9c14309297ecef85deb25645e"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.67/prices.json"
    sha256 "ffc8da83c2202a3ada0d97912f7d919508e8a2f2da83e7f2182b68914556273e"
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
