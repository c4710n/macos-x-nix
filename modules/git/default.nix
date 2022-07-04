{ pkgs, username, ... }:

let
  guess-commiter-bin = ".config/git/guess-commiter";
in
{
  home-manager.users."${username}" = {
    programs.git = rec {
      enable = true;

      aliases = {
        # log
        lg =
          "log --oneline --decorate --color --graph --all --abbrev-commit --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";

        # assume unchanged
        au-list = ''!git ls-files -v | grep \"^[a-z]\"'';
        au-add = "update-index --assume-unchanged";
        au-remove = "update-index --no-assume-unchanged";
        au-refresh =
          "update-index --really-refresh"; # remove all aussume unchanged file

        # count commits by authors
        who = "shortlog -sn";

        # ignored
        ignored = ''!git status -s --ignored | grep \"^!!\"'';

        # commit
        cm = "commit -m";

        # reauthor
        quick-reauthor = "reauthor -c";

        # guess commiter
        guess-commiter = "!~/${guess-commiter-bin}";
      };

      lfs.enable = true;

      extraConfig = {
        core = {
          quotepath = false;
          autocrlf = "input";
          safecrlf = true;
          compression = 9;
        };

        user = {
          # disable guessing user.name and user.email,
          # commiter need to set them explicitly.
          useConfigOnly = true;
        };

        credential.helper = "cache";
        push.followTags = true;

        color.ui = "true";

        "diff \"gpg\"".textconv = "gpg --no-tty --decrypt";
        "diff \"nodiff\"".command =
          if pkgs.stdenv.isDarwin
          then "/usr/bin/true"
          else "/bin/true";
      };
    };

    xdg.configFile."git/ignore".source = ./files/ignore;
    xdg.configFile."git/attributes".source = ./files/attributes;

    home.file."${guess-commiter-bin}" = {
      executable = true;
      source = ./files/guess-commiter;
    };

    programs.bash.initExtra = (builtins.readFile ./files/bashrc.sh);
    programs.bash.shellAliases.",ggr" = ''cd "$(git root)" && pwd'';

    home.packages = with pkgs; [
      gitAndTools.git-extras
      git-crypt
      git-sizer
      gh

      subversion # `svn export` is useful
    ];
  };
}
