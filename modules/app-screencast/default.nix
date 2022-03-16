{ pkgs, lib, username, ... }:

with lib;

{
  homebrew.casks = [
    "keycastr"
  ];
}
