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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.61/cloudcosttree-darwin-arm64"
      sha256 "3931a83b14574f9abff22666330fb201faecf5870d1180731ebc2395d21fc0b0"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.61/cloudcosttree-darwin-amd64"
      sha256 "df5fd54c0f5181051d2f2ba299e3f1050b0cfd87fc9549d0b379aea0c025fed7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.61/cloudcosttree-linux-arm64"
      sha256 "2649cf92f7a327f8423fbc46394d307996cb7b3692e1da2e401df8ea2377362b"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.61/cloudcosttree-linux-amd64"
      sha256 "492cfa44c975bfd41574ebf76cd2de115ce641d5acfcc191d1a2b86749fabe09"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.61/prices.json"
    sha256 "223b1f6bc2be7d93865d969435b8c8f1d26bbecf8831a730e1c4670ab8c2f4d2"
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
