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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.40/cloudcosttree-darwin-arm64"
      sha256 "c7d00c565a7f8b9f1875b93b587809a4895fc7e3a297eb1a33571948b1c2d452"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.40/cloudcosttree-darwin-amd64"
      sha256 "82e4f6d1ebe8ca02c7c14f13a8d95f00f249899d7c6a0786bafa86b9016a8725"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.40/cloudcosttree-linux-arm64"
      sha256 "759414e1892597b13d883bf09598598379149590e291b7d64ac1959facc0a05e"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.40/cloudcosttree-linux-amd64"
      sha256 "3801295f086b942382c564d4ed5ee39a7d4c786ee0058a23be9755171796836d"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.40/prices.json"
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
