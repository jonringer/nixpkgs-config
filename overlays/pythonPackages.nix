self: super:
let
  myOverride = {
    packageOverrides = self: super: {
      pylint = super.pylint.overrideAttrs (old: rec {
        pname = "pylint";
        version = "2.3.1";

        src = super.fetchPypi {
          inherit pname version;
          sha256 = "1wgzq0da87m7708hrc9h4bc5m4z2p7379i4xyydszasmjns3sgkj";
        };
      });

      astroid = super.astroid.overrideAttrs (old: rec {
        pname = "astroid";
        version = "2.2.5";

        src = super.fetchPypi {
          inherit pname version;
          sha256 = "1x5c8fiqa18frwwfdsw41lpqsyff3w4lxvjx9d5ccs4zfkhy2q35";
        };
      });


    };
  };
in {
  python2 = super.python2.override myOverride;
  python3 = super.python3.override myOverride;
  python35 = super.python35.override myOverride;
  python36 = super.python36.override myOverride;
  python37 = super.python37.override myOverride;
}
