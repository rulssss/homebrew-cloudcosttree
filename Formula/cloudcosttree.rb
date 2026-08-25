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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.0/cloudcosttree-darwin-arm64"
      sha256 "8f2b979131499cea0a63695b6b80b1375d87e790087cf32c796bab1e37fc74a0"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.0/cloudcosttree-darwin-amd64"
      sha256 "fd82576fcc544a024ecf9b143a5612bdd69db2a5407b4145610a3941e478e61c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.0/cloudcosttree-linux-arm64"
      sha256 "d1c63d7b429341f1dd82f3cb07c250c40449c170e9ede2d8ec9e949005d7db6b"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.0/cloudcosttree-linux-amd64"
      sha256 "d2a7566855fec3a50ddb478a14e7c0baa5b4168ee6bc4863f4af65a087c167de"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.0/prices.json"
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
