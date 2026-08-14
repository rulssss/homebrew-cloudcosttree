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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.42/cloudcosttree-darwin-arm64"
      sha256 "1cb3232bfae45d9f500fbde6365d3dfc55133c628fa92f283e8e2faeda509b4a"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.42/cloudcosttree-darwin-amd64"
      sha256 "d2b7385c5415499a92a40461adce198e23d482c1589a482881e3c49e219cd27d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.42/cloudcosttree-linux-arm64"
      sha256 "7d51c13cf4d1d21db2189ec695f7bd00db1e10e19830f1a0e1b42fe6c4f29307"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.42/cloudcosttree-linux-amd64"
      sha256 "46168799af44e4dc9f2654763c8350cce3aaa3c394502c49c327ceb4bf66b8be"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.42/prices.json"
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
