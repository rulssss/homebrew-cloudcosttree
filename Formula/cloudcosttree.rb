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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.68/cloudcosttree-darwin-arm64"
      sha256 "9243d859eb31bd9329f6f96265a894297f67213bfa93f9fb1111ec9564656bd2"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.68/cloudcosttree-darwin-amd64"
      sha256 "6f43a383de455eefe65bf028ccc38e4cf852c7b42a8b94e11453db043dd4e0a1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.68/cloudcosttree-linux-arm64"
      sha256 "38f9f508d000cd9401937ac3eb62ee0a5b1e39d153e7e18beb6a533d0e8c7a00"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.68/cloudcosttree-linux-amd64"
      sha256 "452b1a05ef233201c87ec8aa81a95afe28580ee7c565003d72c5ca366a5790ad"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.68/prices.json"
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
