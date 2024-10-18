{ sources ? import ../nix/sources.nix
, packages ? import sources.nixpkgs {}
, inShell ? null
}:

let
  deps = with packages; [
    tk
    ghostscript
  ];

  drv = packages.stdenv.mkDerivation rec {
    pname = "asterix-specs-syntax";
    version = "0.0";
    src = ./.;
    propagatedBuildInputs = deps;
    buildPhase = ''
    '';
    installPhase = ''
      mkdir -p $out

      ix=$out/index.html
      echo "<!DOCTYPE html>" >> $ix
      echo "<html>" >> $ix
      echo "<head><link href="../style.css" rel="stylesheet" type="text/css"></head>" >> $ix
      echo "<body>" >> $ix
      echo "<ul>" >> $ix

      mkdir -p $out/syntax/sources
      for i in `ls *tcl | grep syntax`; do cp $i $out/syntax/sources; done

      mkdir -p $out/syntax/postscript
      mkdir -p $out/syntax/png
      for i in `ls *ps | grep syntax`; do
        b=$(basename $i .ps)
        cp $i $out/syntax/postscript;
        gs -dSAFER -dBATCH -dNOPAUSE -dEPSCrop -r600 -sDEVICE=pngalpha -sOutputFile=$out/syntax/png/$b.png $i
        echo "<li><a href=syntax/png/$b.png>$b</a></li>" >> $ix
      done

      echo "</ul>" >> $ix
      echo "</body>" >> $ix
      echo "</html>" >> $ix

    '';
  } // { inherit env; };

  env = packages.stdenv.mkDerivation rec {
    name = "asterix-syntax-envorinment";
    buildInputs = deps;
    shellHook = ''
    '';
  };

in
  if inShell == false
    then drv
    else if packages.lib.inNixShell then drv.env else drv

