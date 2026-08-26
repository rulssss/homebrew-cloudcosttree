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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.4/cloudcosttree-darwin-arm64"
      sha256 "4262157c9c254640f307cbc9fab6b02d6fa611859369dc6cce813a2a1ca72fa6"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.4/cloudcosttree-darwin-amd64"
      sha256 "32a3fcc613a6a132e81a2c411043647ff7e65981f6175c530c852e99887cc0dc"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.4/cloudcosttree-linux-arm64"
      sha256 "57e5acbbd5dc90a87fc5c4b408bfa06e2cce5c1d41557f85cbf41eadfa02d828"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.4/cloudcosttree-linux-amd64"
      sha256 "f85686d2d9143bd5dad40c3c822d136f23bafd8daa1e8149ac9c80682ea428db"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.4/prices.json"
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
