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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.10/cloudcosttree-darwin-arm64"
      sha256 "efbc4a46adf04cfdf256f2ecfac5f7ad441b54fdcb5559520d7411e63a7d3525"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.10/cloudcosttree-darwin-amd64"
      sha256 "b50a60aac0cbb1eee56425347269d917dc3ca5b458c1365efd7d136b125414ae"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.10/cloudcosttree-linux-arm64"
      sha256 "541703f1ed9f4a06e3dcaf2a2a4dc9f33f2faf89ac3ded0b6b2890f5c5df87ab"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.10/cloudcosttree-linux-amd64"
      sha256 "48953d752ea363403fd9706450f69b440a9c832c2a3f9ee49eb57457bb3805d6"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.10/prices.json"
    sha256 "8dfee9802980a3bb5eada583bd359688d6420f9e871c812b0de73d9ff341a70b"
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
