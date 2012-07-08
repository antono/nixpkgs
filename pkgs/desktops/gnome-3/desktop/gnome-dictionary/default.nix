{ stdenv, fetchurl, pkgconfig, glib, gtk, gnome_doc_utils, intltool, which }:

stdenv.mkDerivation rec {
  version = "3.5.2";
  name = "gnome-dictionary-${version}";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-dictionary/3.5/${name}.tar.xz";
    sha256 = "1cq32csxn27vir5nlixx337ym2nal9ykq3s1j7yynh2adh4m0jil";
  };

  buildInputs = [ gtk ];
  buildNativeInputs = [ pkgconfig intltool gnome_doc_utils which ];
}
