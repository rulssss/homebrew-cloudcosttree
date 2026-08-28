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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.12/cloudcosttree-darwin-arm64"
      sha256 "6a57860bf374c69bbcf2288034e103627ea18ed62960c9fa49461b8e384d9474"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.12/cloudcosttree-darwin-amd64"
      sha256 "fd17ebea76348b7d8bfe6d91a8b7efb42dec1d56118858c52f3d75fffa3e6542"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.12/cloudcosttree-linux-arm64"
      sha256 "57a048e40ed8bc3b8646afe4c2b364ec4ad399dff1b0125e3b8c2420a7c268af"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.12/cloudcosttree-linux-amd64"
      sha256 "dfc1b439481f4dc2d219362d67382078e388331f011d71cecbb48f79edf6a518"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.12/prices.json"
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
