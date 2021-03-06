{ cabal, mtl, network, parsec }:

cabal.mkDerivation (self: {
  pname = "HTTP";
  version = "4000.2.3";
  sha256 = "1z7s5rkyljwdl95cwqbqg64i207wjwxgpksrdmvcv82k39srzx80";
  buildDepends = [ mtl network parsec ];
  meta = {
    homepage = "https://github.com/haskell/HTTP";
    description = "A library for client-side HTTP";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ self.stdenv.lib.maintainers.andres ];
  };
})
