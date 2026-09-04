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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.18/cloudcosttree-darwin-arm64"
      sha256 "a94fd5f07e20e2932a2e170f037dbc71979dd3de95b5d2f925189f6ccd1e1fd4"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.18/cloudcosttree-darwin-amd64"
      sha256 "f517ff54c7cd7b10036115a0203507f3b90f6dd7b9e91c5c9c55bf4f228702d0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.18/cloudcosttree-linux-arm64"
      sha256 "a427bb2fc7c2fdaa303dc1b1b01e0eb105c07dc9287a1c72b48f096d0283f206"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.18/cloudcosttree-linux-amd64"
      sha256 "ee7afd6a8e1fb76267c577a22f222305d4570d2e02cc462c455c3c83209f9f5a"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.18/prices.json"
    sha256 "2234ac420795c52ec4003b7cbad715b370a4321af2e9f11a1bb3702c476a4f85"
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
