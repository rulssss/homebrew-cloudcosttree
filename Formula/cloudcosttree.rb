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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.54/cloudcosttree-darwin-arm64"
      sha256 "258a742f6712b79b30c0a310ee7397438d3922505861bd946f59800705a9ff18"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.54/cloudcosttree-darwin-amd64"
      sha256 "505ca39fbda20d5f79300e3bb41c63f6e84db5b5c990dfa379f9c5a20a1cc681"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.54/cloudcosttree-linux-arm64"
      sha256 "e2351f089ba657e8a870fa697d5f31fb614bc35eb8b43a80bf24d6d87fc7653a"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.54/cloudcosttree-linux-amd64"
      sha256 "5aa155e9acc8ded1975ec48c9ada573a328993c323aa5b60bcd80c15a95d2292"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.54/prices.json"
    sha256 "628ad4fb9e298f1dcebdf7795dfd98b397cab1d13a4a268d5bbae7810dfd1cee"
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
