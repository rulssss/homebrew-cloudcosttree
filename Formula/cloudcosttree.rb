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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.63/cloudcosttree-darwin-arm64"
      sha256 "dab31345dd4112bd30e6898e269e9ce991df7be9d50bb0fc85e756c2dd05efa7"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.63/cloudcosttree-darwin-amd64"
      sha256 "bbdf173970f2238257db7302dc341a3832a113e376b0a7bf4d9c3c12f9e08c60"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.63/cloudcosttree-linux-arm64"
      sha256 "ef0c671a6d6ded4a9ef0b4f3714d0a784a2a7ae29973077c4f439f8c6975d9b8"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.63/cloudcosttree-linux-amd64"
      sha256 "0b8ae3b632f4a943809ebef70a91c5e44bd5ee2e00f072644326180205067ca0"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.63/prices.json"
    sha256 "2888e9c8767adddfc7e8117ef3cfed7a94595a31dc3f101ecac8bcc101d50bfe"
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
