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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.23/cloudcosttree-darwin-arm64"
      sha256 "b19a2afd71107d9033c4920f87826f49bf1401164645362c0f5e1d7ff327d02a"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.23/cloudcosttree-darwin-amd64"
      sha256 "31a3fdc88015a1f01186fb3b15a641a4355a1be731bc0446f7529c9067a37922"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.23/cloudcosttree-linux-arm64"
      sha256 "8581f05267b96d258b854b2ddda05de24da746f209c11ede7a9ab19c298d454e"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.23/cloudcosttree-linux-amd64"
      sha256 "7696c0c5e43e3b76b04e4ff4bb43ad7844ce278a39bcdf8757f2a6982be5a18d"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.23/prices.json"
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
