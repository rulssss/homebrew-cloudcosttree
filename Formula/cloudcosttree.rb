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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.62/cloudcosttree-darwin-arm64"
      sha256 "c10ef99197b8e77e034108669c14f63bbbfa544eaed74b9a65bda1e8260ab659"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.62/cloudcosttree-darwin-amd64"
      sha256 "2b0841db0c824e8db232720935d79eb946eaffb08de8c65fc50a8ba96edeacd5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.62/cloudcosttree-linux-arm64"
      sha256 "6890940d73aa0fcef228bb8d29239c94af849aa52a255fa92c4aad5c4a657054"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.62/cloudcosttree-linux-amd64"
      sha256 "5c8fae8a1eafd2a5a969c0955c7ca72995f86edd360d26714dfb372563a716cc"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.62/prices.json"
    sha256 "04a4d0138a096d66f4d6ae4a6fe7812abebd82fd658a8422251a881c104df7ca"
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
