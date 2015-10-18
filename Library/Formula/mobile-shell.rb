class MobileShell < Formula
  desc "Remote terminal application"
  homepage "https://mosh.mit.edu/"
  url "https://mosh.mit.edu/mosh-1.2.5.tar.gz"
  sha256 "1af809e5d747c333a852fbf7acdbf4d354dc4bbc2839e3afe5cf798190074be3"

  bottle do
    sha256 "046b0c48cd1c573d57500e683122e3152a00556ad960938c6caa962b0c2ef460" => :el_capitan
    sha256 "33719bc3df39cf2fdeb4589129f164f3500d2eac1e874666c747b612384545cf" => :yosemite
    sha256 "9460c06ccef476ef1b3feed85168ea989ef4eced753cbd59ed53fd512f5c1aff" => :mavericks
    sha256 "5a244c07094d5d3d30a95888a7bb0df6051fd81cfec7fd35ac861090f1897d6e" => :mountain_lion
  end

  head do
    url "https://github.com/mobile-shell/mosh.git", :shallow => false

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  option "without-check", "Run build-time tests"

  depends_on "pkg-config" => :build
  depends_on :autoconf => :build if MacOS.version == :tiger
  depends_on :automake => :build if MacOS.version == :tiger
  depends_on "openssl"
  depends_on "protobuf"

  # Support Tiger's forkpty in util.h
  patch do
    url "https://gist.githubusercontent.com/ahihi/73419893bb2790cafa1a/raw/d4b2d7b38f61b5643885941cbbff4b972eb56973/mosh-osx-10.4-forkpty.patch"
    sha256 "22a574267cc4f00fcec2ff83c18cc01852c19ff560a9d798e3962c43e1dd7a4c"
  end if MacOS.version == :tiger
  
  # Remove unsetenv() return value checks on Tiger, since it returns void
  patch do
    url "https://gist.githubusercontent.com/ahihi/73419893bb2790cafa1a/raw/61513df6bc42b5518a4120ab57fddce7aa6a8903/mosh-osx-10.4-unsetenv-void.patch"
    sha256 "5201af360497bc283adb7874ae3e860d4a29f17af86b818c4a252d19258d86fa"
  end if MacOS.version == :tiger

  def install
    # teach mosh to locate mosh-client without referring
    # PATH to support launching outside shell e.g. via launcher
    inreplace "scripts/mosh.pl", "'mosh-client", "\'#{bin}/mosh-client"

    # Upstream prefers O2:
    # https://github.com/keithw/mosh/blob/master/README.md
    ENV.O2
    system "./autogen.sh" if build.head? || MacOS.version == :tiger
    system "./configure", "--prefix=#{prefix}", "--enable-completion"
    system "make", "check" if build.with?("check") || build.bottle?
    system "make", "install"
  end

  test do
    ENV["TERM"] = "xterm"
    system "#{bin}/mosh-client", "-c"
  end
end
