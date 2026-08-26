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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.6/cloudcosttree-darwin-arm64"
      sha256 "9ddca8312f5913a835158da479f1656f7db417879c7fac2e4480e9f197b3fc28"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.6/cloudcosttree-darwin-amd64"
      sha256 "fdd25a28c0856a0d4ca4750f9e67424b2acfe158e4bbc4446f054ade6a7ff866"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.6/cloudcosttree-linux-arm64"
      sha256 "c6f3931db03d690f58ce8b2ba395372e077fc289e490920fbfd1eb402016c676"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.6/cloudcosttree-linux-amd64"
      sha256 "61a6c1b4214a245fd5c4f31161d5288ae6ad96f95e599aae47a3f24d86592f99"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.6/prices.json"
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
