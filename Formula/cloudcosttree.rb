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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.16/cloudcosttree-darwin-arm64"
      sha256 "805c560e7806962c7a799ac2511dc644fad6c9105962b8487400eafa6fed7b1a"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.16/cloudcosttree-darwin-amd64"
      sha256 "792e3232cd3a1741b6d8121692f772599880fee650d04b06a97edbb7f46ffb05"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.16/cloudcosttree-linux-arm64"
      sha256 "b851001360aac32b792f75156c9e33ca891426c63fb49f60abdd3a9e9393f3aa"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.16/cloudcosttree-linux-amd64"
      sha256 "33c4d1f4a79f1b7d2fc8584118256df9daeaa481163c3f1577bdee8834adc585"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.16/prices.json"
    sha256 "fd11adadd3c45e9df191fd33e490b67e8267a002397e84bfe82aa1d73c6e88f3"
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
