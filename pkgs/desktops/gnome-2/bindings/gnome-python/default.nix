{ stdenv, fetchurl, python, pkgconfig, libgnome, GConf, pygobject, pygtk, glib, gtk, pythonDBus}:

with stdenv.lib;

stdenv.mkDerivation rec {
  version = "2.28";
  name = "gnome-python-${version}.1";

  src = fetchurl {
    url = "http://ftp.gnome.org/pub/GNOME/sources/gnome-python/${version}/${name}.tar.bz2";
    sha256 = "759ce9344cbf89cf7f8449d945822a0c9f317a494f56787782a901e4119b96d8";
  };

  phases = "unpackPhase configurePhase buildPhase installPhase";

  # You should be using WAF instead; see the file INSTALL.WAF
  configurePhase = ''
    python waf configure --prefix=$out
  '';

  buildPhase = ''
    python waf build
  '';

  installPhase = ''
    python waf install
  '';

  buildInputs = [ python pkgconfig pygobject pygtk glib gtk GConf libgnome pythonDBus ];

  doCheck = false;

  meta = {
    homepage = "http://projects.gnome.org/gconf/";
    description = "Python wrapper for gconf";
    maintainers = [ stdenv.lib.maintainers.qknight ];
  };
}