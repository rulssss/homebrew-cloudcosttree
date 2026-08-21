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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.64/cloudcosttree-darwin-arm64"
      sha256 "88ce57ef2b37636ab73a3892e3fc750cd82769f419e43a5373061f9c02dc4586"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.64/cloudcosttree-darwin-amd64"
      sha256 "ec885cb1689e9911fe28d79e9f368a34cbb77ca28cd2914532554e752a9ee8f8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.64/cloudcosttree-linux-arm64"
      sha256 "c134d32815d9095640677cec5480b83d07d585bffa10d19141abd5c9f4fb8d72"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.64/cloudcosttree-linux-amd64"
      sha256 "041a710a287c4a447733c323240fc7686285950bbd8514ca02e965e75a4519e9"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.64/prices.json"
    sha256 "d64559e44676687bafb78300557ffbe2c347175dcfc6a98bb7faa3eafa5c040f"
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
