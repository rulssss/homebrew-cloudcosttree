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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.39/cloudcosttree-darwin-arm64"
      sha256 "9d556201a6b70b84aa86fd12b027f7a1dbe164550b26fe88c3e7b8a3f2da5114"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.39/cloudcosttree-darwin-amd64"
      sha256 "45bc337fd2a95772c58201f3b9b9f891d4e7375df1deacb143b69fd96d95f459"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.39/cloudcosttree-linux-arm64"
      sha256 "5a8ece50554f3bc119de1c925cd2f426a9c3a14886bfef6709ac4fb0286a0c09"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.39/cloudcosttree-linux-amd64"
      sha256 "2d40bebf1a8f143393e1a787c580ad4ab3846f681f413acfc8c31175c91360c7"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.39/prices.json"
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
