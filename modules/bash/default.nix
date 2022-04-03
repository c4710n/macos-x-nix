# $HOME/.profile - bash.sessionVariables
# $HOME/.profile - bash.profileExtra
# $HOME/.bashrc  - bash.initExtra

{ pkgs, lib, username, ... }:


lib.mkMerge [
  {
    home-manager.users."${username}" = {
      programs.bash = {
        enable = true;
        shellOptions = [ ];

        profileExtra = lib.mkBefore ''
          # enable job control
          set -m

          # disable Ctrl-s
          stty -ixon

          # BASTION
          # - a directory for storing miscellaneous data.
          export BASTION_BASE=$HOME/_BASTION_
          export BASTION_ROOT=$HOME/_BASTION_/root
          export BASTION_SLOTS=$BASTION_ROOT/slots
          export PATH=$BASTION_CORE/bin:$PATH

          # load bin from slots
          slots=$(command ls $BASTION_SLOTS)
          for slot in $slots; do
            bin_dir=$BASTION_SLOTS/$slot/bin
            if [[ -d "$bin_dir" ]]; then
              export PATH=$bin_dir:$PATH
            fi
          done
          unset slots
          unset slot
          unset bin_dir
        '';

        sessionVariables = {
          TERM = "xterm-256color";

          LANG = "en_US.UTF-8";
          LC_COLLATE = "C";

          # less
          LESS = " -R ";
        };

        initExtra = ''
          # PS1
          export PS1="\n \$ ";
        '';

        shellAliases = {
          # sudo
          _ = "sudo env PATH=$PATH";

          # ls
          ls = "ls -F";

          # cd
          ".." = "cd .."; # Go up one directory
          "..." = "cd ../.."; # Go up two directories
          "...." = "cd ../../.."; # Go up three directories

          # - unscaped version: clear && printf '\e[3J'";
          # - ⌘ + K do the same thing on macOS
          ",cls" = ''
            clear && printf '\e[3J'
          '';
        };
      };
    };
  }

  # fix prompt
  {
    home-manager.users."${username}" = {
      programs.bash.initExtra = ''
        # fix PROMOPT_COMMAND for macOS
        export PROMPT_COMMAND="echo -ne '\033]0;''${USER}@''${HOSTNAME}\007';$PROMPT_COMMAND"
      '';
    };
  }

  # safer rm
  {
    home-manager.users."${username}" = {
      programs.bash.shellAliases = {
        "rm" = "Use trash.";
        "rmdir" = "Use trash.";
      };
    };

    homebrew.brews = [ "macos-trash" ];
  }

  # readline
  {
    home-manager.users."${username}" = {
      home.file.".inputrc".text = ''
        $include /etc/inputrc
        set completion-ignore-case on
        set editing-mode emacs

        $if mode=emacs
        "\eh": backward-kill-word
        $endif
      '';
    };
  }

  # auto completion
  {
    home-manager.users."${username}" = {
      programs.bash.initExtra = ''
        # Bash Completion
        if shopt -q progcomp &> /dev/null; then
          . "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
          nullglobStatus=$(shopt -p nullglob)
          shopt -s nullglob

          for p in $NIX_PROFILES; do
            for m in "$p/etc/bash_completion.d/"*; do
              . $m
            done

            for n in "$p/share/bash-completion/completions/"*; do
              . $n
            done
          done

          eval "$nullglobStatus"
          unset nullglobStatus p m n
        fi
      '';
    };
  }

  # disable history
  {
    home-manager.users."${username}" = {
      programs.bash = {
        historyFile = "";

        sessionVariables = {
          SHELL_SESSION_HISTORY = 0;
        };
      };
    };
  }

  # starship
  {
    home-manager.users."${username}" = {
      programs.bash.initExtra = ''
        function set_win_title(){
            echo -ne "\033]0; $(basename "$PWD") \007"
        }
        starship_precmd_user_func="set_win_title"
      '';

      programs.starship = {
        enable = true;
        enableBashIntegration = true;
        enableFishIntegration = false;
        enableZshIntegration = false;
        settings = {
          git_commit.disabled = true;
          git_state.disabled = true;
          git_status.disabled = true;

          package.disabled = true;

          hg_branch.disabled = true;

          battery = {
            full_symbol = "";
            charging_symbol = "";
            discharging_symbol = "";
          };
        };
      };
    };
  }

  # jump dir quickly
  {
    home-manager.users."${username}" = {
      programs.autojump.enable = true;
    };
  }
]
