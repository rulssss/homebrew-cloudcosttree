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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.15/cloudcosttree-darwin-arm64"
      sha256 "4660e993e25dde988b0ca15d3957b71d31ca8201a9608d5eb983b94b1678a07d"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.15/cloudcosttree-darwin-amd64"
      sha256 "122da5a6317f96673d83f84a3af697df9c5f313e92f7e893671801604382026e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.15/cloudcosttree-linux-arm64"
      sha256 "113a08e624840094820b65aefef9a05615f2f3f1b1768c21dbf527bfc2b2ff4f"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.15/cloudcosttree-linux-amd64"
      sha256 "3b0ed11fc7c06bf6a9d67030e5b4fdab5e45a2912f37fe369203a657b3b42295"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.15/prices.json"
    sha256 "677029057527d44d323fe243be4a9a9d9febf4d4dd6fbfc644b7c3510e5d1a12"
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
