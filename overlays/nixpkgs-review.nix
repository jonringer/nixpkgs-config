self: super: {
  nixpkgs-review = super.nixpkgs-review.overrideAttrs(oldAttrs: rec {
    name = "nixpkgs-review-unstable-2020-09-28";
    src = super.fetchFromGitHub {
      owner = "mic92";
      repo = "nixpkgs-review";
      rev= "fb6143435e91756f7447c34653d96de4c7c1be21";
      sha256 = "04g2b3nj1ayn4vrqhgslpmmij4sd1c0d4m3acg9a9r3w5hnsjxvv";
    };
  });
}
