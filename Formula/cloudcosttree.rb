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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.43/cloudcosttree-darwin-arm64"
      sha256 "2dbd6bfe1247dc7e2d3238e574acc5f43946fd721d76f378a55d02092fcd8360"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.43/cloudcosttree-darwin-amd64"
      sha256 "52722a1754500655375eca538f913303f7cb5fde2c97ed3d7f720158701e3056"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.43/cloudcosttree-linux-arm64"
      sha256 "e1c34152689f76278c68aba31664e423e2393d57f946a62afc089dd084f8e5c8"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.43/cloudcosttree-linux-amd64"
      sha256 "8025f295062084012bb5c948553a3fa83694c4242edbbe747bf765024fc3a8a4"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.43/prices.json"
    sha256 "f76bf3b154ea69fd0115db5ef414fe648590f138b306c497718d8fcb4ae5bc6c"
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
