{ stdenv, fetchurl, zlib, libjpeg }:

stdenv.mkDerivation {
  name = "splashutils-1.5.4.3";

  src = fetchurl {
    url = http://dev.gentoo.org/~spock/projects/splashutils/current/splashutils-1.5.4.3.tar.bz2;
    sha256 = "0vn0ifqp9a3bmprzx2yr82hgq8m2y5xv8qcifs2plz6p3lidagpg";
  };

  buildInputs = [ zlib libjpeg ];
  
  configureFlags = "--without-ttf --without-png --without-gpm --with-themedir=/etc/splash KLCC=gcc";

  dontDisableStatic = true;

  preConfigure = ''
    configureFlags="$configureFlags --with-essential-prefix=$out"
    substituteInPlace src/common.h \
      --replace 'FBSPLASH_DIR"/sys"' '"/sys"' \
      --replace 'FBSPLASH_DIR"/proc"' '"/proc"'
    substituteInPlace src/Makefile.in \
      --replace '-all-static' "" \
      --replace '-static' ""
  '';

  CPP = "gcc -E";
  CXXCPP = "g++ -E";
  NIX_CFLAGS_COMPILE = "-fPIC";

  passthru = {
    helperName = "sbin/fbcondecor_helper";
    controlName = "sbin/fbcondecor_ctl";
    helperProcFile = "/proc/sys/kernel/fbcondecor";
  };
}
