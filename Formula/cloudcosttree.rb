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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.19/cloudcosttree-darwin-arm64"
      sha256 "0b1fd3b70dbd6787cd4ad61baebf7f0d7fc97ca091c02da1f012c4e3a4a567c1"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.19/cloudcosttree-darwin-amd64"
      sha256 "3d90b0697a67b1f0acbcf86e9308516a4cf781a685aa3afde595c1d54277aa12"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.19/cloudcosttree-linux-arm64"
      sha256 "8253f008142d6427616969170d30b7bec063ba4661c8da965835ad8d59dc16e6"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.19/cloudcosttree-linux-amd64"
      sha256 "e87453a6edef66bc6db86aa492a75ecb50b6752306f12046011d7dcc09a8a5a7"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.19/prices.json"
    sha256 "b00da62c100a6ae97eb3b664e7664cc534b20262a084e4d5b68623c5f7ab7483"
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
