{
  description = "ss4r-generator";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    
    let build_for = system:
                  
      let pkgs = import nixpkgs {
        inherit system;
      };
        
      in pkgs.clangStdenv.mkDerivation {

          pname = "ss4r-generator";
          version = "0.0.2";

          srcs = [
            (pkgs.fetchFromGitHub {
              owner = "admb-project";
              repo = "admb";
              rev = "admb-13.2";
              name = "admb";
              sha256 = "z7S3MqT6TQH8GW5VImCzmBnk+7XQmHeEN7ocmBHGUqg=";
            })
            (pkgs.fetchFromGitHub {
              owner = "nmfs-ost";
              repo = "ss3-source-code";
              rev = "v3.30.22.1";
              name = "ss3";
              sha256 = "r/grfMvbna6XpfovOiT96d7Mm4o06l4WzGX3VFGojYQ=";
            })
            (pkgs.fetchFromGitHub {
              owner = "nmfs-ost";
              repo = "ss3-test-models";
              rev = "ad02c34";
              name = "data";
              sha256 = "2nqEzzKQROlsmS9SLZ+H3Fv/QDWKUeedVZdX+1w8eqw=";
            })
            (pkgs.lib.fileset.toSource {
              root = ./.;
              fileset = ./ss4r-mocking;
            })
          ];

          sourceRoot = ".";
      
          buildInputs = [ pkgs.flex pkgs.R pkgs.rPackages.Rcpp pkgs.rPackages.roxygen2];

          buildPhase = ''
            flex admb/src/nh99/tpl2cpp.lex
            sed -f admb/src/nh99/sedflex lex.yy.c > tpl2cpp.c
            clang tpl2cpp.c -o tpl2cpp
            cat ss3/SS_biofxn.tpl ss3/SS_miscfxn.tpl ss3/SS_selex.tpl ss3/SS_popdyn.tpl ss3/SS_recruit.tpl ss3/SS_benchfore.tpl ss3/SS_expval.tpl ss3/SS_objfunc.tpl ss3/SS_write.tpl ss3/SS_write_ssnew.tpl ss3/SS_write_report.tpl ss3/SS_ALK.tpl ss3/SS_timevaryparm.tpl ss3/SS_tagrecap.tpl > SS_functions.temp
            cat ss3/SS_versioninfo_330safe.tpl ss3/SS_readstarter.tpl ss3/SS_readdata_330.tpl ss3/SS_readcontrol_330.tpl ss3/SS_param.tpl ss3/SS_prelim.tpl ss3/SS_global.tpl ss3/SS_proced.tpl SS_functions.temp > ss3.tpl
            ./tpl2cpp ss3
            cp admb/src/linad99/*.* .
            mv expm.cpp linexpm.cpp
            cp admb/src/nh99/*.* .          
            cp admb/src/tools99/*.* .
            cp admb/src/df1b2-separable/*.* .
            cp admb/src/sparse/*.* .
            sed -i 's/#include <admodel.h>/#include "admodel.h"/g' *.*
            sed -i 's/#  include <admodel.h>/#include "admodel.h"/g' *.*
            sed -i 's/#include <fvar.hpp>/#include "fvar.hpp"/g' *.*
            sed -i 's/#  include <fvar.hpp>/#include "fvar.hpp"/g' *.*
            sed -i 's/#include <df1b2fun.h>/#include "df1b2fun.h"/g' *.*
            sed -i 's/#  include <df1b2fun.h>/#include "df1b2fun.h"/g' *.*
            sed -i 's/#include <df1b2loc.h>/#include "df1b2loc.h"/g' *.*
            sed -i 's/#include <adrndeff.h>/#include "adrndeff.h"/g' *.*
            sed -i 's/#  include <adrndeff.h>/#include "adrndeff.h"/g' *.*
            sed -i 's/#include <tiny_ad.hpp>/#include "tiny_ad.hpp"/g' *.*
            sed -i 's/#include <dfpool.h>/#include "dfpool.h"/g' *.*
            sed -i 's/#include <ivector.h>/#include "ivector.h"/g' *.*
            sed -i 's/#include <gradient_structure.h>/#include "gradient_structure.h"/g' *.*
            sed -i 's/#include <imatrix.h>/#include "imatrix.h"/g' *.*
            sed -i 's/#include <adstring.hpp>/#include "adstring.hpp"/g' *.*
            sed -i 's/#include <cifstrem.h>/#include "cifstrem.h"/g' *.*
            sed -i 's/#include <Vectorize.hpp>/#include "Vectorize.hpp"/g' *.*
            sed -i 's/#include <adpool.h>/#include "adpool.h"/g' *.*
            sed -i 's/#include <tiny_wrap.hpp>/#include "tiny_wrap.hpp"/g' *.*
            sed -i 's/#include <integrate_wrap.hpp>/#include "integrate_wrap.hpp"/g' *.*
            sed -i 's/#include <df32fun.h>/#include "df32fun.h"/g' *.*
            sed -i 's/#include <df1b2fnl.h>/#include "df1b2fnl.h"/g' *.*
            sed -i 's/#include <df3fun.h>/#include "df3fun.h"/g' *.*
            sed -i 's/#include "\.\.\/linad99\/betacf_val.hpp"/#include "betacf_val.hpp"/g' *.*
            sed 's/std::scientific < setp/std::scientific << std::setp/g' xfmmtr1.cpp > xfmmtr1.cpp
            sed 's/#include "tweedie_logW.cpp"//g' dtweedie.cpp > dtweedie2.cpp
            cat tweedie_logW.cpp >> dtweedie2.cpp
            mv dtweedie2.cpp dtweedie.cpp
            rm tweedie_logW.cpp
            sed "s/abs(\(.*parm_1(j, 8) > 0\))/\1/g" ss3.cpp > ss31.cpp
            sed -e '/#include <ss3.htp>/rss3.htp' ss31.cpp > ss32.cpp
            sed "s/#include <ss3.htp>//g" ss32.cpp > ss33.cpp
            mv ss33.cpp ss3.cpp
            rm ss3.htp
            rm ss31.cpp
            rm ss32.cpp
            rm getopt.cpp
            sed -e '/#include "integrate.cpp"/rintegrate.cpp' integrate.hpp > integrate2.hpp
            sed 's/#include "integrate.cpp"//g' integrate2.hpp > integrate3.hpp
            mv integrate3.hpp integrate.hpp
            rm integrate2.hpp
            rm integrate.cpp
            rm evalxtrn.cpp
            sed -e '/#include "fvar.hpp"/rfvar2.cpp' fvar1.cpp > fvar.cpp            
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp
            rm fvar1.cpp fvar2.cpp
            sed -e '/#include "fvar.hpp"/rfvar_a10.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a11.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp
            sed -e '/#include "fvar.hpp"/rfvar_a13.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a14.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a15.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a16.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a17.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a18.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a19.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a20.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a21.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a22.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a23.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a24.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a25.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a26.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a27.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a28.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a29.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a30.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a31.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a32.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a33.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a34.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a35.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a36.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a37.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a38.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a39.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a40.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a41.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a42.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a43.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a44.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a45.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a46.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a47.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a48.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a49.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a50.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a51.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a52.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a53.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a54.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a55.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a56.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a57.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a58.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a59.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_a60.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp
            ls | grep -P "^fvar_a[0-5][0-9].*$" | xargs -d"\n" rm
            rm fvar_a60.cpp
            sed -e '/#include "fvar.hpp"/rfvar_ar1.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_ar3.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_ar7.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_ar8.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            ls | grep -P "^fvar_ar[0-9].*$" | xargs -d"\n" rm
            sed -e '/#include "fvar.hpp"/rfvar_arr.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp                   
            sed -e '/#include "fvar.hpp"/rfvar_dif.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_fn.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_fn1.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_fn2.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            rm fvar_arr.cpp fvar_dif.cpp fvar_fn.cpp fvar_fn1.cpp fvar_fn2.cpp
            sed -e '/#include "fvar.hpp"/rfvar_m10.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp                                    
            sed -e '/#include "fvar.hpp"/rfvar_m11.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp
            sed -e '/#include "fvar.hpp"/rfvar_m12.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp
            sed -e '/#include "fvar.hpp"/rfvar_m13.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m14.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m15.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m18.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m19.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            rm fvar_m10.cpp fvar_m11.cpp fvar_m12.cpp fvar_m13.cpp fvar_m14.cpp fvar_m15.cpp fvar_m18.cpp fvar_m19.cpp
            sed -e '/#include "fvar.hpp"/rfvar_m20.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp                        
            sed -e '/#include "fvar.hpp"/rfvar_m21.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m22.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m23.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m24.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m27.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m28.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m29.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            rm fvar_m20.cpp fvar_m21.cpp fvar_m22.cpp fvar_m23.cpp fvar_m24.cpp fvar_m27.cpp fvar_m28.cpp fvar_m29.cpp
            sed -e '/#include "fvar.hpp"/rfvar_m30.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m31.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m32.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m33.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m34.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m35.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m36.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m37.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m38.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m39.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            ls | grep -P "^fvar_m3[0-9].*$" | xargs -d"\n" rm
            sed '228d' fvar_m40.cpp > fvar_m40_tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m40_tmp.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp
            rm fvar_m40_tmp.cpp
            sed -e '/#include "fvar.hpp"/rfvar_m41.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m42.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m43.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m44.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m45.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m46.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m47.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            sed -e '/#include "fvar.hpp"/rfvar_m48.cpp' tmp.cpp > fvar.cpp
            sed '0,/#include "fvar.hpp"/{/#include "fvar.hpp"/d;}' fvar.cpp > tmp.cpp            
            ls | grep -P "^fvar_m4[0-8].*$" | xargs -d"\n" rm
            mv tmp.cpp fvar.cpp            
            mv Vectorize.hpp vectorize.h
            sed -i 's/Vectorize.hpp/vectorize.h/g' *.*
            mv adoption.hpp adoption.h
            sed -i 's/adoption.hpp/adoption.h/g' *.*
            mv adstring.hpp adstring.h
            sed -i 's/adstring.hpp/adstring.h/g' *.*
            mv betacf_val.hpp betacf_val.h
            sed -i 's/betacf_val.hpp/betacf_val.h/g' *.*
            mv fvar.hpp fvar.h
            sed -i 's/fvar.hpp/fvar.h/g' *.*
            mv integrate.hpp integrate.h
            sed -i 's/integrate.hpp/integrate.h/g' *.*
            mv integrate_wrap.hpp integrate_wrap.h
            sed -i 's/integrate_wrap.hpp/integrate_wrap.h/g' *.*
            rm tiny_ad.hpp tiny_vec.hpp tiny_wrap.hpp
            rm df1b2bet.cpp
            sed -i '116,119d' adjson.cpp
            sed -i '46d;47d;64d;65d;84d;85d;125d;132d;185d;221d;232d;308d;309d;310d;373d;374d;411d;412d;439d;440d;' adpool.cpp
            sed -i '67d' amoeba.cpp
            sed -i '50d' betacf_val.h
            sed -i '55d;56d;61d;62d;' c_ghk.cpp
            sed -i '103d;121d;227d;244d;' cbessel.cpp
            sed -i '89,102d' df1b2fun.h
            sed -i '118,122d' fvar.h            
            sed -i '14d;15d;16d;17d;18d;19d;22d;23d;24d;' vbetacf.cpp
            sed 's/int Do_Selex_Std;/int Do_Selex_Std=0;/g' ss3.cpp > ss31.cpp
            sed 's/int Selex_Std_AL;/int Selex_Std_AL=1;/g' ss31.cpp > ss32.cpp
            sed 's/int Selex_Std_Cnt;/int Selex_Std_Cnt=0;/g' ss32.cpp > ss33.cpp
            sed 's/int Do_Growth_Std;/int Do_Growth_Std=0;/g' ss33.cpp > ss34.cpp
            sed 's/int Growth_Std_Cnt;/int Growth_Std_Cnt=0;/g' ss34.cpp > ss35.cpp
            sed 's/int Do_NatAge_Std;/int Do_NatAge_Std=0;/g' ss35.cpp > ss36.cpp
            sed 's/int NatAge_Std_Cnt;/int NatAge_Std_Cnt=0;/g' ss36.cpp > ss37.cpp
            sed 's/int Do_NatM_Std;/int Do_NatM_Std=0;/g' ss37.cpp > ss38.cpp
            sed 's/int NatM_Std_Cnt;/int NatM_Std_Cnt=0;/g' ss38.cpp > ss39.cpp
            sed 's/int Do_Dyn_Bzero;/int Do_Dyn_Bzero=0;/g' ss39.cpp > ss310.cpp
            sed 's/int Do_se_smrybio;/int Do_se_smrybio=0;/g' ss310.cpp > ss311.cpp
            sed 's/int Do_se_LnSSB;/int Do_se_LnSSB=0;/g' ss311.cpp > ss312.cpp
            sed 's/int SzFreq_Nmeth;/int SzFreq_Nmeth=0;/g' ss312.cpp > ss313.cpp
            rm ss3.cpp ss31.cpp ss32.cpp ss33.cpp ss34.cpp ss35.cpp ss36.cpp ss37.cpp ss38.cpp ss39.cpp ss310.cpp ss311.cpp ss312.cpp
            mv ss313.cpp ss3.cpp
            printf '// [[Rcpp::export]]\nint call_ss3_notmain(const int x) {\n char * argv = "ss3";\n int argc = 1;\n int retnm = notmain(argc, &argv);\n return (retnm+1);\n}' >> ss3.cpp            
            sed 's/int main(int/int notmain(int/g' ss3.cpp > ss3_tmp.cpp
            rm ss3.cpp
            mv ss3_tmp.cpp ss3.cpp
            sed -i '1s/^/#include <Rcpp.h>\n/' ss3.cpp
            Rscript -e 'Rcpp::Rcpp.package.skeleton("ss4r", path=".", cpp_files=Sys.glob(c("*.cpp","*.h")), example_code=FALSE, attributes=TRUE)'
	    cp source/ss4r-mocking
	    Rscript -e 'roxygen2::roxygenise("ss4r")'
	    rm ss4r/Read-and-delete-me
 	    rm ss4r/src/*.o
            rm ss4r/src/*.so
          '';

          installPhase = ''
            mkdir -p $out/r-package
            cp -r ss4r $out/r-package
          '';
        };

      in 

      {
        packages.x86_64-linux.default = build_for "x86_64-linux";
        packages.aarch64-darwin.default = build_for "aarch64-darwin";
      };    
}

#            clang++ -c *.cpp
#            clang++ *.o -o ss3o
#            mkdir -p $out/bin
#            install -t $out/bin ss3o
#            mkdir -p $out/data
#            cp source/models/Simple/starter.ss $out/data
#            cp source/models/Simple/control.ss $out/data
#            cp source/models/Simple/data.ss $out/data
#            cp source/models/Simple/forecast.ss $out/data
