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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.38/cloudcosttree-darwin-arm64"
      sha256 "5fc55aaf8f901b69045207eb9d79b881206c11b352fa99153f76bbf0e69ba6ba"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.38/cloudcosttree-darwin-amd64"
      sha256 "ef9cdd7542a516c528b1d03b3457efc81bb775bc4233b47af2154c19e30636c6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.38/cloudcosttree-linux-arm64"
      sha256 "797d0cbb7c344485be83a9cc6865c9565fd83f8eafa6dabd61eda9857624e1be"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.38/cloudcosttree-linux-amd64"
      sha256 "3dac0231e88b655fa16556d76c554f52322f04e09104f9cf8e61b971b0f6dc55"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.38/prices.json"
    sha256 "2cc20f3cd7777df75bc0d49ea30bf37eb6c3e5cfe987f7e524325d1c788860ae"
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
