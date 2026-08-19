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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.58/cloudcosttree-darwin-arm64"
      sha256 "8b5849c56adb930af272c02d17ec5fded6a6835c3fe3adfe21297f1312db2a67"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.58/cloudcosttree-darwin-amd64"
      sha256 "1a92a48baa8c4d63fdcd13675ffd7f4f8fb63a96b37df9346d7a32c4aa1be1d0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.58/cloudcosttree-linux-arm64"
      sha256 "fa40cace8da389d24e341bada796173c7a98533088c4feebda097fb7b74d5327"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.58/cloudcosttree-linux-amd64"
      sha256 "652e03575c9756c88f2ea8071fabb3eb3a7fb0f3f5e46b825c359813137347ca"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.58/prices.json"
    sha256 "53ae88d481f2f18c7aa874ecfac76c42efeca1913c0c3b3c84ec4808fb81282b"
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
