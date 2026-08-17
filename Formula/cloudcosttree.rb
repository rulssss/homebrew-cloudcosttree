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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.46/cloudcosttree-darwin-arm64"
      sha256 "3eb0d6db0a01f0eab396b45ccf7fb38a2751ee7254069fa078d4909c4b128e5b"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.46/cloudcosttree-darwin-amd64"
      sha256 "25bf00a88fd4be857ff4f57d45c1b51f24bcd6371c7352ae28d317b3893d79da"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.46/cloudcosttree-linux-arm64"
      sha256 "5b13fac61ab3619d1d2702daee636a18c96af18dc82470816e6fb03049875d8e"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.46/cloudcosttree-linux-amd64"
      sha256 "4cd81f3b0063efd9daa19e8c1a6de4066ab9f5abe400f659a2b43ed9d1fd24ac"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.46/prices.json"
    sha256 "f76bf3b154ea69fd0115db5ef414fe648590f138b306c497718d8fcb4ae5bc6c"
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
