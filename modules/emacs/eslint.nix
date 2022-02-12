{ pkgs, username, ... }:

{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      nodePackages.eslint
    ];

    home.file.".eslintrc.yml".text = ''
      parserOptions:
        sourceType: module
      env:
        browser: true
        node: true
        es6: true
        es2017: true
        es2020: true
        es2021: true
        jquery: true
      extends: eslint:recommended
      rules:
        # Override default settings
        strict: off
        no-unused-vars:
          - "error"
          - "argsIgnorePattern": "^_"
    '';
  };
}
