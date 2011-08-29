{stdenv, fetchurl, perl, ncurses, gmp}:

let
  supportedPlatforms = ["x86_64-linux" "i686-linux" "x86_64-darwin"];
in

assert stdenv.lib.elem stdenv.system supportedPlatforms;

stdenv.mkDerivation rec {
  version = "7.0.4";

  name = "ghc-${version}-binary";

  src =
    if stdenv.system == "i686-linux" then
      fetchurl {
        url = "http://haskell.org/ghc/dist/${version}/ghc-${version}-i386-unknown-linux.tar.bz2";
        sha256 = "0mfnihiyjl06f5w1yrjp36sw9g67g2ymg5sdl0g23h1pab99jx63";
      }
    else if stdenv.system == "x86_64-linux" then
      fetchurl {
        url = "http://haskell.org/ghc/dist/${version}/ghc-${version}-x86_64-unknown-linux.tar.bz2";
        sha256 = "0mc4rhqcxz427wq4zgffmnn0d2yjqvy6af4x9mha283p1gdj5q99";
      }
    else if stdenv.system == "x86_64-darwin" then
      fetchurl {
        url = "http://haskell.org/ghc/dist/${version}/ghc-${version}-x86_64-apple-darwin.tar.bz2";
        sha256 = "1m2ml88p1swf4dnv2vq8hz4drcp46n3ahpfi05wh01ajkf8hnn3l";
      }
    else throw "cannot bootstrap GHC on this platform";

  buildInputs = [perl];

  postUnpack =
    # Strip is harmful, see also below. It's important that this happens
    # first. The GHC Cabal build system makes use of strip by default and
    # has hardcoded paths to /usr/bin/strip in many places. We replace
    # those below, making them point to our dummy script.
     ''
      mkdir "$TMP/bin"
      for i in strip; do
        echo '#!/bin/sh' >> "$TMP/bin/$i"
        chmod +x "$TMP/bin/$i"
        PATH="$TMP/bin:$PATH"
      done
     '' +
    # We have to patch the GMP paths for the integer-gmp package.
     ''
      find . -name integer-gmp.buildinfo \
          -exec sed -i "s@extra-lib-dirs: @extra-lib-dirs: ${gmp}/lib@" {} \;
     '' +
    # On Linux, use patchelf to modify the executables so that they can
    # find editline/gmp.
    (if stdenv.isLinux then ''
      find . -type f -perm +100 \
          -exec patchelf --interpreter "$(cat $NIX_GCC/nix-support/dynamic-linker)" \
          --set-rpath "${ncurses}/lib:${gmp}/lib" {} \;
      sed -i "s|/usr/bin/perl|perl\x00        |" ghc-${version}/ghc/stage2/build/tmp/ghc-stage2
      sed -i "s|/usr/bin/gcc|gcc\x00        |" ghc-${version}/ghc/stage2/build/tmp/ghc-stage2
      for prog in ld ar gcc strip ranlib; do
        find . -name "setup-config" -exec sed -i "s@/usr/bin/$prog@$(type -p $prog)@g" {} \;
      done
     '' else "");

  configurePhase = ''
    ./configure --prefix=$out --with-gmp-libraries=${gmp}/lib --with-gmp-includes=${gmp}/include
  '';

  # Stripping combined with patchelf breaks the executables (they die
  # with a segfault or the kernel even refuses the execve). (NIXPKGS-85)
  dontStrip = true;

  # No building is necessary, but calling make without flags ironically
  # calls install-strip ...
  buildPhase = "true";

  # The binaries for Darwin use frameworks, so fake those frameworks,
  # and create some wrapper scripts that set DYLD_FRAMEWORK_PATH so
  # that the executables work with no special setup.
  postInstall =
    (if stdenv.isDarwin then
      ''
        ensureDir $out/frameworks/GMP.framework/Versions/A
        ln -s ${gmp}/lib/libgmp.dylib $out/frameworks/GMP.framework/GMP
        ln -s ${gmp}/lib/libgmp.dylib $out/frameworks/GMP.framework/Versions/A/GMP
        # !!! fix this

        mv $out/bin $out/bin-orig
        mkdir $out/bin
        for i in $(cd $out/bin-orig && ls); do
            echo "#! $SHELL -e" >> $out/bin/$i
            echo "DYLD_FRAMEWORK_PATH=$out/frameworks exec $out/bin-orig/$i -framework-path $out/frameworks \"\$@\"" >> $out/bin/$i
            chmod +x $out/bin/$i
        done
      '' else "")
    +
      ''
        # bah, the passing gmp doesn't work, so let's add it to the final package.conf in a quick but dirty way
        # sed -i "s@^\(.*pkgName = PackageName \"rts\".*\libraryDirs = \\[\)\(.*\)@\\1\"${gmp}/lib\",\2@" $out/lib/ghc-${version}/package.conf

        # Sanity check, can ghc create executables?
        cd $TMP
        mkdir test-ghc; cd test-ghc
        cat > main.hs << EOF
          module Main where
          main = putStrLn "yes"
        EOF
        $out/bin/ghc --make main.hs
        echo compilation ok
        [ $(./main) == "yes" ]
      '';

  meta.platforms = supportedPlatforms;
}