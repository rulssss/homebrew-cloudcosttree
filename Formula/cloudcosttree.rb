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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.56/cloudcosttree-darwin-arm64"
      sha256 "7acc1d73b2bdf9bc1b553ffa2ca9272b95a3fabc912a20f22c830a0d22388580"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.56/cloudcosttree-darwin-amd64"
      sha256 "493a3202ef5fb5f9ed3994c970332b6c351d987d0422f6e4b80403d33451b026"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.56/cloudcosttree-linux-arm64"
      sha256 "e4a72d347f9e3dbb67d3b381899acbafe1abebf04d22effdd422521296f76d68"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.56/cloudcosttree-linux-amd64"
      sha256 "496af5836d360e0fd3bcc88bbd9f36b9099803adc95218801d5866bc4ade6f32"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.56/prices.json"
    sha256 "d15366f6a78c4f7f5077f06b42a40f16f76b68c00d195e0174070f51d518deff"
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
