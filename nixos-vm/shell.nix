{ system ? builtins.currentSystem }:

let
  sources = import ../nix/sources.nix;
  pkgs = import sources.nixos { inherit system; };

  sshPrivateKey = ../secrets/nixos-vm-ssh-key-private;
in
pkgs.mkShell {
  # I prefer overriding NIX_PATH rather than using `nix.nixPath`:
  # + https://discourse.nixos.org/t/nixops-pinning-nixpkgs/734/3
  # + https://github.com/NixOS/nixops/issues/736#issuecomment-333658173
  NIX_PATH = "nixpkgs=${toString pkgs.path}";

  # force Morph to use specified SSH private key in this repo, instead of keys
  # in SSH agent. SSH_CONFIG_FILE is an env supported by Morph.
  SSH_CONFIG_FILE = pkgs.writeText "ssh-config" ''
    Host *
      IdentityFile ${sshPrivateKey}
      IdentitiesOnly yes
  '';

  # force SSH to use specified SSH private key in this repo, instead of keys
  # in SSH agent.
  buildInputs = [
    pkgs.nixos-generators

    (pkgs.writeScriptBin "vm-deploy" ''
      #!${pkgs.stdenv.shell}

      VM_NAME=$1

      morph deploy ./vm/$VM_NAME/morph.nix switch
    '')
  ];
}
