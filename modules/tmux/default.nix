# Usage:
#
# Start this command `/run/current-system/sw/bin/tmux new-session -A -s main` in terminal.
#
{ config, username, pkgs, ... }:

{
  environment.systemPackages = [
    # link tmux installed by home-manager to /run/current-system/sw/bin/tmux
    (
      let
        tmux = config.home-manager.users."${username}".programs.tmux.package;
      in
      pkgs.writeScriptBin "tmux" ''
        #!${pkgs.stdenv.shell}

        exec ${tmux}/bin/tmux $@
      ''
    )
  ];

  home-manager.users."${username}" = {
    # tmux
    programs.tmux = {
      enable = true;
      keyMode = "emacs";
      extraConfig = ''
        set -g prefix C-z

        # index window and pane from 1
        set  -g base-index      1
        setw -g pane-base-index 1
        setw -g main-pane-width 60%
        setw -g main-pane-height 60%

        # start a fresh login shell
        set-option -g default-command "/usr/bin/env -i USER=$USER HOME=$HOME $SHELL -l -i"

        # adjust position and style for default status bar
        set-option -g status-position top
        set-option -g status-style fg=black,bg=default

        # adjust style for message
        set-option -g message-style fg=magenta,bg=#efefef

        # enable status bar for panes
        set-option -g pane-border-status top

        # disable status-right
        set-option -g status-right ""
        set-option -g status-right-length 0

        # unbind C-z for preventing me suspend the tmux client accidently.
        unbind C-z

        # switch current pane with pane specified by provided pane index
        bind-key h command-prompt -p 'swap current pane with pane # :' "swap-pane -t '%%'"

        # make copy-mode works on macOS
        bind-key -T copy-mode M-w send-keys -X copy-pipe "${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace pbcopy"

        # reload config
        bind-key r source-file ~/.config/tmux/tmux.conf \; display "Config Reloaded!"
      '';
    };
    # Tips:
    # + tmux kill-server : cleanly and gracefully kill all tmux open sessions (and server).
    # + tmux kill-session -a : close all other sessions except current one.
    # + tmux list-sessions : list all sessions
    # + tmux kill-session -t <target_session> : to kill that specific session.
    # + pkill -f tmux - kill tmux processes grossly.

    # tmux session manager
    programs.tmux.tmuxinator.enable = true;
    programs.bash.shellAliases.",ts" = "tmuxinator";
  };
}
