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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.44/cloudcosttree-darwin-arm64"
      sha256 "d947aa6695412e95d121d49892649fab2d1655bee9ba4ab991211606bd42e488"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.44/cloudcosttree-darwin-amd64"
      sha256 "c105b51efd6fee2e40278fe6d79ec110e4581b7bf68550feaff4106400d67f99"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.44/cloudcosttree-linux-arm64"
      sha256 "04b74980d5aeb81fab22bd6e5799d49995b8270db384e8eb1336c39a7ef93726"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.44/cloudcosttree-linux-amd64"
      sha256 "760ebbdfd4eadd65bb0c5c63cb0a4879e80f41fd692b877fa1746faf45817138"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.44/prices.json"
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
