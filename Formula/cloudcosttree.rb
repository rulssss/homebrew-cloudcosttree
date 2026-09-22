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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.26/cloudcosttree-darwin-arm64"
      sha256 "3addfbc9327f3302788047d20515bacfbbb316ad63af063fbec0e17a0b8c88e2"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.26/cloudcosttree-darwin-amd64"
      sha256 "eecde07dcf216b9ca475846a03b45ed85633f87b7f403c2fc0e1263a6585dd57"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.26/cloudcosttree-linux-arm64"
      sha256 "d6299a197d78aad110c4a070ad6564ec615905d754b2eeb9ab406cad83d76fd4"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.26/cloudcosttree-linux-amd64"
      sha256 "331f5c2717f891a1e86bcfc02617a89ff895e58a4ac4eec5c4718658fdbb788d"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.26/prices.json"
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
