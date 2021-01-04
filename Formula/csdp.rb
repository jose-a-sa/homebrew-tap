class Csdp < Formula
  desc "Semidefinite programming problems"
  homepage "https://github.com/coin-or/Csdp"
  url "https://github.com/coin-or/Csdp/archive/releases/6.2.0.tar.gz"
  sha256 "3d341974af1f8ed70e1a37cc896e7ae4a513375875e5b46db8e8f38b7680b32f"
  license "EPL-2.0"

  bottle do
    root_url "https://github.com/mahrud/homebrew-tap/releases/download/csdp-6.2.0"
    cellar :any_skip_relocation
    sha256 "5a0accab8c702cde119e5c9444a5043bee73a5de7f12b10ee9380930f2a5b982" => :x86_64_linux
  end

  depends_on "libomp" if OS.mac?
  depends_on "lapack" unless OS.mac?

  # patch for compatibility with macOS
  patch do
    url "https://raw.githubusercontent.com/Macaulay2/M2/1f99f71a1308318679412de7f20e940b05f80be6/M2/libraries/csdp/patch-6.2.0"
  end

  def install
    # inreplace "Makefile", "/usr/local", "$(prefix)"

    if OS.mac?
      libomp = Formula["libomp"]
      ENV["OpenMP_C_FLAGS"] = "-Xpreprocessor\ -fopenmp\ -I#{libomp.opt_include}"
      ENV["OpenMP_C_LDLIBS"] = "#{libomp.opt_lib}/libomp.a"
      ENV["LA_LIBRARIES"] = "-framework Accelerate"
    else
      ENV["OpenMP_C_FLAGS"] = "-fopenmp"
      ENV["LA_LIBRARIES"] = "-llapack -lblas"
    end

    mkdir bin
    system "make",
           "CC=#{ENV.cc} ${OpenMP_C_FLAGS} ${CFLAGS}",
           "LDLIBS=${OpenMP_C_LDLIBS}",
           "LIBS=-L../lib -lsdp ${LA_LIBRARIES} -lm"
    system "make", "prefix=#{prefix}", "install"
  end

  test do
    system "true"
  end
end