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
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.66/cloudcosttree-darwin-arm64"
      sha256 "c899be603b36a6cb16e751e784a1c12a7615eb0fc451f21588a7072a0885fc9d"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.66/cloudcosttree-darwin-amd64"
      sha256 "4d765321e414a1c26fabef7101eadfa30c11fc23a9c8b554c613abdbcee95458"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.66/cloudcosttree-linux-arm64"
      sha256 "4f02a4e0403e1674ade3e6991cca2f7688e6579105f19280595f60c3a35a2187"
    else
      url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.66/cloudcosttree-linux-amd64"
      sha256 "e0d0ef243c8cddfd71397cedd774b978bd27f4c6d525790e8a00c9ac1e810f06"
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
    url "https://github.com/rulssss/cloudcosttree/releases/download/v0.1.66/prices.json"
    sha256 "1fb241982df30f4870776c74173f4a03a2138cef55ca39bc69fdc2e0cec439ab"
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
