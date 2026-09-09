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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.22/cloudcosttree-darwin-arm64"
      sha256 "c348ff46e6c5b78025545f1b0d4d57336782e6195e280a87bdf78ca010124c2b"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.22/cloudcosttree-darwin-amd64"
      sha256 "774456d54ee6a60ab5dc6636a322846e0f9077b0b9cb83f48d9991e48c3d1feb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.22/cloudcosttree-linux-arm64"
      sha256 "bc18d79d4bc7fdbf4831631029f1d4ba1cb7e3e5a9d7a9ce6fe358df21593fe5"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.22/cloudcosttree-linux-amd64"
      sha256 "adc890e2f9c2203c20f72f6d4efa7d906b78a05b55959798f7251b107f85b6ff"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.22/prices.json"
    sha256 "7ed50ff12c37fc13b4aec7baed4e303beccf1dbed595770fa6d593d24ab8d88c"
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
