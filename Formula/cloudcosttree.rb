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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.9/cloudcosttree-darwin-arm64"
      sha256 "e7fbad94cb6bdf6dd49e908282570be2022cce5aaec2bdd6c75565ad19a71f54"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.9/cloudcosttree-darwin-amd64"
      sha256 "c9d65ea86b48b0dc319844b1fe9eadc37cf7dfca15398d60d92655a5f37194db"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.9/cloudcosttree-linux-arm64"
      sha256 "816a71e2e933d3269f38c3cf3dc1b435c0d9dd29674750726ba2526604b03951"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.9/cloudcosttree-linux-amd64"
      sha256 "ad390dc7c5e180e28b01f28fff4a30b5e93a52245527125fab7647503ea6a4bd"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.2.9/prices.json"
    sha256 "8dfee9802980a3bb5eada583bd359688d6420f9e871c812b0de73d9ff341a70b"
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
