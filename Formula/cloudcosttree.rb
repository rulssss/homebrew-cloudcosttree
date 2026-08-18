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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.53/cloudcosttree-darwin-arm64"
      sha256 "e66259f2fa61142d5fb433309ea9861ae0537efbade85e58fedb3fecb9ce49c0"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.53/cloudcosttree-darwin-amd64"
      sha256 "4d6b2a77e4a1f6943d77965de99bf5ef81215f13b8e29b3afaa687c320a874b3"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.53/cloudcosttree-linux-arm64"
      sha256 "21642d21a25f464f1078fd9791c299b0542d225e9f52337607127b353c4c4807"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.53/cloudcosttree-linux-amd64"
      sha256 "fe8b266cb04ddd8d749617d65172aee47bce727c5a554486b344f0c0b430b2f7"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.53/prices.json"
    sha256 "628ad4fb9e298f1dcebdf7795dfd98b397cab1d13a4a268d5bbae7810dfd1cee"
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
