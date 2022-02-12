## SSH ##
# override default ssh
ssh() {
    SSH_DIR=$HOME/.ssh
    SSH_CONFIG=$SSH_DIR/config
    KEYLIST_FILE=$SSH_DIR/keychain_helper
    PLUGINS=$(command ls $BASTION_PLUGINS)

    mkdir -p $SSH_DIR

    echo "" > $SSH_CONFIG
    echo "" > $KEYLIST_FILE

    for PLUGIN in $PLUGINS; do
        CURRENT_DIR=$BASTION_PLUGINS/$PLUGIN/ssh
        CONFIG=$CURRENT_DIR/config
        KEY_DIR=$CURRENT_DIR/keys

        if [[ -f "$CONFIG" ]]; then
            echo "" >> $SSH_CONFIG
            echo "# DERIVED FROM PLUGIN - $PLUGIN" >> $SSH_CONFIG
            echo "" >> $SSH_CONFIG
            sed -e "s|__DIR__|$CURRENT_DIR|g" $CURRENT_DIR/config >> $SSH_CONFIG
        fi

        if [[ -d "$KEY_DIR" ]]; then
            find $KEY_DIR -type f  | egrep -v '\.pub$' >> $KEYLIST_FILE
        fi
    done

    chmod 600 $SSH_CONFIG
    TERM=xterm-256color
    command ssh "$@"
}

# enhanced scp
alias ,scp='rsync -avzP'

# generate strong keys
alias ,ssh-keygen-strong='ssh-keygen -t ed25519 -a 100';

alias ,ssh-pubkey-fingerprint='ssh-keygen -l -f';

# load ssh keys specified in $HOME/.ssh/keychain_helper
,keychain_helper() {
    KEYLIST_FILE=$HOME/.ssh/keychain_helper

    echo ""

    if [[ -f "$KEYLIST_FILE" ]]; then
        cd "$SSH_USER"
        echo -e " \033[1;32m*\033[0m\033[1;35m keychain\033[0m initializing..."
        eval "$(xargs -a $KEYLIST_FILE keychain --eval --nogui --quiet --agents ssh)"
        cd - > /dev/null 2>&1
        echo ""
    else
        echo -e " \033[1;32m*\033[0m\033[1;35m keychain\033[0m skip."
        echo ""
        return
    fi
}

,keychain_helper
