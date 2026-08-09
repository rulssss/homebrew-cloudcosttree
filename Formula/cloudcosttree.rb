class Cloudcosttree < Formula
  desc "Estimate AWS infrastructure costs in a hierarchical tree before you apply"
  homepage "https://cloudcosttree.com"
  # version is inferred from the release URL below (redundant to also set it
  # explicitly, per `brew audit`). :cannot_represent is Homebrew's own
  # documented way to mark a real, intentional non-SPDX (proprietary)
  # license, not a placeholder for "unknown."
  license :cannot_represent

  on_macos do
    url Hardware::CPU.arm? ? "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.36/cloudcosttree-darwin-arm64" : "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.36/cloudcosttree-darwin-amd64"
    sha256 Hardware::CPU.arm? ? "9b82dcc315c1bb21261890fdc2b4b53ae1cd9128005096ced4e068bc248a69a8" : "d68a5db22b3d1f00f787df1ff141994bf7a70cf25cb124b3b23b79d9161cbf31"
  end

  on_linux do
    url Hardware::CPU.arm? ? "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.36/cloudcosttree-linux-arm64" : "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.36/cloudcosttree-linux-amd64"
    sha256 Hardware::CPU.arm? ? "e77fb111e752f0227754d99aaafb5a7b868878491473a65549ee4bf6def591c1" : "94136765233f3827561a055cf1a03d632091650131ccd239f33e29c01846fe72"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.36/prices.json"
    sha256 "be41c71d7800bd2b12e0ded79b26265900140fa2e974f3505940cf967ec50c86"
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
