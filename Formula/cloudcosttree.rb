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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.14/cloudcosttree-darwin-arm64"
      sha256 "c5f51009eab83a3df4a5e0bb70700a82519262d973d587b247f17e49de8fa13e"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.14/cloudcosttree-darwin-amd64"
      sha256 "7a2edc0afa6e0ab0ae1a60fd638ab6e69c2261d940d88b6db10dd6cff96d4782"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.14/cloudcosttree-linux-arm64"
      sha256 "0ebe8bcacb13e2bf5012e4f83be8b9446fbe1662533e847085a9b120101dcd2d"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.14/cloudcosttree-linux-amd64"
      sha256 "aadd990aa47ad4de3940829ee1f5fbb2c9728beac08b4ea0ae7d2c8508881659"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.14/prices.json"
    sha256 "af7313c7bb074d25353dff47f5b87fc8136ee7037cf9c8a8355dcd3db824ea77"
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
