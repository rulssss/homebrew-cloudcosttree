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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.50/cloudcosttree-darwin-arm64"
      sha256 "20a4d513607dbe123d52fd038109fc4132aabdfdc7f951a546bcac329b3b22be"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.50/cloudcosttree-darwin-amd64"
      sha256 "1adf9f4eda25f832090cac10d53597ac664027182a5ed6243a74c8f92b36602f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.50/cloudcosttree-linux-arm64"
      sha256 "ad7fe4d3754a3eb2f365dfc87b4167b9b44cdef8807b142d27c11aec88d2509d"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.50/cloudcosttree-linux-amd64"
      sha256 "d54828dbe31d7eb968b6a7c23585543bd686375e95649ff4496f341ea3073c5b"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.50/prices.json"
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
