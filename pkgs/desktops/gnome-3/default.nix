{ callPackage, self, stdenv, gettext, overrides ? {} }:
{
  __overrides = overrides;

#### PLATFORM


#### DESKTOP

  gnome_dictionary = callPackage ./desktop/gnome-dictionary { };
}
