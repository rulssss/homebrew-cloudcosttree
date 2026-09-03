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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.17/cloudcosttree-darwin-arm64"
      sha256 "2da51bdee45d7daa65f38179f58a83f643a2e7a6e7f8cd9e80fb8bbad1d82a57"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.17/cloudcosttree-darwin-amd64"
      sha256 "fd955fb6dfbded52ee55744647aa4c7b3ae966f4cff9f11555f85f01b600cf2d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.17/cloudcosttree-linux-arm64"
      sha256 "1a97b9ba05ea06badad440a817b19819158fbf7b9c6f026eefe274e4cb0ab3de"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.17/cloudcosttree-linux-amd64"
      sha256 "916273a617e6805a22716b3762ffc490348e3204d0c907f472875d68a550c4dc"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.17/prices.json"
    sha256 "49cba9ed8031371dac8301767998883711f159cd28b6d68337bf24efe04f6977"
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
