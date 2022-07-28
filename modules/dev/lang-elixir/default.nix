{ pkgs, username, ... }:

{
  homebrew = {
    # TODO: upgrade macOS SDK
    #
    # 2021/10/16
    # wxmac is required by Erlang observer tool.
    # But it doesn't work as expected, because wxmac is compiled with old macOS
    # SDK - 10.12 which doesn't support dark-mode.
    #
    # This issue is hard to fix, I have to wait Nix team.
    # + https://github.com/NixOS/nixpkgs/issues/116341
    # + https://github.com/NixOS/nixpkgs/issues/101229
    #
    # So, for now, I install another version of elixir provided by homebrew
    # in order to use `observer.start()`.
    #
    #
    # Usage:
    #   $ ,brew-use-path
    #   $ iex

    brews = [ "elixir" ];
  };


  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      erlangR24
      unstable.beam.packages.erlangR24.elixir_1_13
      # custom.plds
    ];

    programs.bash.profileExtra = ''
      export PATH="$HOME/.mix/escripts:$PATH"
    '';

    programs.bash.initExtra = ''
      ## ELIXIR ##
      _is_mix_project() {
        if [[ ! -f mix.exs ]]; then
          echo "Not a mix project, exit."
          return 1
        else
          return 0
        fi
      }

      # remove unused deps from deps/ and mix.lock
      ,mix-deps-cleanup() {
        if ! _is_mix_project; then
          return
        fi

        mix deps.clean --unused --unlock
      }

      # rebuild deps
      ,mix-deps-rebuild() {
        if ! _is_mix_project; then
          return
        fi

        echo "cleaning deps/ _build/ mix.lock ..."
        command rm -rf _build/ deps/ mix.lock

        echo "rebuilding..."
        mix deps.get
        mix deps.compile
      }

      ,phx-release() {
        mix deps.get --only prod
        MIX_ENV=prod mix compile
        npm run deploy --prefix ./assets
        mix phx.digest
        MIX_ENV=prod mix release
      }

      ,erlang-version() {
        erl -noshell -eval \
        '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version).' -eval 'halt().'
      }

      ,elixir-version() {
        mix run -e 'IO.puts(System.version)'
      }
    '';
  };
}
