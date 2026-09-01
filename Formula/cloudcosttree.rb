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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.13/cloudcosttree-darwin-arm64"
      sha256 "90d71e5d8b80722019b1bd9c520b6838bd4ac6d5a5876ad33a641ca98b6ca957"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.13/cloudcosttree-darwin-amd64"
      sha256 "d093b3d04586c29dbb6e7f0ed3b7a1e188aad086a4e7855bcecb6e2142f3689d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.13/cloudcosttree-linux-arm64"
      sha256 "d30d7f2347bc68d8fa55544d0c139d4376e1ea9f97f682d121dac0739fe74684"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.13/cloudcosttree-linux-amd64"
      sha256 "997e88db85d6665b495d1b959746b81a8003262ade7be432fd9bc9408833acd1"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.13/prices.json"
    sha256 "1c7a09031295524f19e7cab47c608f3bc8901280999b611b3d44cb7c48acaf1d"
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
