# Font Packaging

What follows is not meant to be a comprehensive specification or
policy statement. It is meant to be a quick introduction to font
packaging in Nix. You are encouraged to ask on the [nix-devel][NIXML]
mailing list if you have any questions regarding fonts in NixOS that
are not covered below.

## Font Naming

Packages that contain fonts should be named in the form of a tuple,
such as `fonts-NAME`. If desired the foundry (maker of the font) may
be included as well, i.e. `fonts-FOUNDRY-name`.

## Font Location

The files corresponding to a given font are installed in directories
dependent on the type and name of the font. The fonts must be stored
in a directory named as /usr/share/fonts/fonttype/name/, where
fonttype is the type (OpenType, TrueType, Type1, etc).

As an example, the Linux Libertine fonts distributed in OpenType
format should be put in the directory:

    $out/share/fonts/opentype/linuxlibertine/

While the Rufscript font distributed in TrueType format should be put
in the directory:

    $out/share/fonts/truetype/rufscript

## Packaging Example

    { stdenv, fetchurl, unzip }:

    stdenv.mkDerivation rec {
      name = "fonts-ubuntu-0.80";
      buildInputs = [ unzip ];
    
      src = fetchurl {
        url = "http://font.ubuntu.com/download/${name}.zip";
        sha256 = "0k4f548riq23gmw4zhn30qqkcpaj4g2ab5rbc3lflfxwkc4p0w8h";
      };
    
      installPhase =
        ''
          mkdir -p $out/share/fonts/truetype/ubuntu
          cp *.ttf $out/share/fonts/truetype/ubuntu
        '';
    
      meta = {
        description = "Ubuntu Font Family";
        longDescription = "The Ubuntu typeface has been specially
          created to complement the Ubuntu tone of voice. It has a
          contemporary style and contains characteristics unique to
          the Ubuntu brand that convey a precise, reliable and free attitude.";
        homepage = http://font.ubuntu.com/;
        license = "free";
        platforms = stdenv.lib.platforms.all;
        maintainers = [ stdenv.lib.maintainers.antono ];
      };
    }


This document based on [Debian Fonts Packaging Policy][DEBFNT].

[NIXML]: http://lists.science.uu.nl/mailman/listinfo/nix-dev
[DEBFNT]: http://wiki.debian.org/Fonts/PackagingPolicy
