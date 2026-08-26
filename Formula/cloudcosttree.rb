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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.3/cloudcosttree-darwin-arm64"
      sha256 "44c265fc33a97293e6bcdb2a08e17b7530f5aa7a01a1a1554fc8bff8e21ea99b"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.3/cloudcosttree-darwin-amd64"
      sha256 "bad7bee319673ba2685300aa76de846968fc122516d00f844b373d747d34bbae"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.3/cloudcosttree-linux-arm64"
      sha256 "ebf59db9e8fc1e61b59aa49364727d3c031db4f5fbdc24e13cbe0894c853747d"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.3/cloudcosttree-linux-amd64"
      sha256 "a604aa34ae6b5fb773662fdad5d358370a68278565e6419f161d95a73bbb9fa8"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.3/prices.json"
    sha256 "ffc8da83c2202a3ada0d97912f7d919508e8a2f2da83e7f2182b68914556273e"
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
