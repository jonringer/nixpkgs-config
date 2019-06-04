self: super:
let
  myOverride = {
    packageOverrides = self: super: {
    };
  };
in {
  python2 = super.python2.override myOverride;
  python3 = super.python3.override myOverride;
  python35 = super.python35.override myOverride;
  python36 = super.python36.override myOverride;
  python37 = super.python37.override myOverride;
}
