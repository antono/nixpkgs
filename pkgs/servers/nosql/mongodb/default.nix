{ stdenv, fetchurl, scons, which, boost, gnutar, v8 ? null, useV8 ? false}:

assert useV8 -> v8 != null;

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "mongodb-2.0.6";

  src = fetchurl {
    url = "http://downloads.mongodb.org/src/mongodb-src-r2.0.6.tar.gz";
    sha256 = "0kiiz8crx318sdn0wd9d88pzx9s1c6ak2dhd0zw7kl63gmd74wm9";
  };

  buildInputs = [scons which boost] ++ stdenv.lib.optional useV8 v8;

  enableParallelBuilding = true;

  patchPhase = ''
    substituteInPlace SConstruct --replace "Environment( MSVS_ARCH=msarch , tools = [\"default\", \"gch\"], toolpath = '.' )" "Environment( MSVS_ARCH=msarch , tools = [\"default\", \"gch\"], toolpath = '.', ENV = os.environ )"
    substituteInPlace SConstruct --replace "../v8" "${v8}"
    substituteInPlace SConstruct --replace "LIBPATH=[\"${v8}/\"]" "LIBPATH=[\"${v8}/lib\"]"
  '';

  buildPhase = ''
    export TERM=""
    scons all --cc=`which gcc` --cxx=`which g++` --libpath=${boost}/lib --cpppath=${boost}/include \
              ${optionalString useV8 "--usev8"}
  '';

  installPhase = ''
    scons install --cc=`which gcc` --cxx=`which g++` --libpath=${boost}/lib --cpppath=${boost}/include \
                  ${optionalString useV8 "--usev8"} --full --prefix=$out
    if [ -d $out/lib64 ]; then
      mv $out/lib64 $out/lib
    fi
  '';

  meta = {
    description = "a scalable, high-performance, open source NoSQL database";
    homepage = http://www.mongodb.org;
    license = "AGPLv3";

    maintainers = [ stdenv.lib.maintainers.bluescreen303 ];
    platforms = stdenv.lib.platforms.all;
  };
}

