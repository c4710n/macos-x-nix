{ pkgs }:

(pkgs.mix-to-nix.mixToNix {
  src = fetchGit {
    url = "https://github.com/phoenixframework/plds.git";
    ref = "820600e8da6e13f376f8341cb78868bc189ddad8";
  };
}).overrideAttrs (super: {
  # don't run test
  doCheck = false;

  postBuild = ''
    mix escript.build --no-deps-check
  '';

  installPhase = "install -Dt $out/bin plds";
})
