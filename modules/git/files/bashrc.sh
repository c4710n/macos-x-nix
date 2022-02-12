# GIT ##
,git-all() {
    GIT_BIN=$(which git)

    ARGS_COUNT=$#
    ACTION=$1
    REPOS=$2
    BRANCH=$3

    # Following code make these 2 commands available.
    #   git push all
    #   git push all $BRANCH
    if [ "$ACTION" = 'push' ] && [ "$REPOS" = 'all' ]; then
        case $ARGS_COUNT in
            2)
                # push all branches to all remotes
                $GIT_BIN remote |
                    xargs -I {} sh -c "echo '>>> Pushing all branches to {}...'; $GIT_BIN push --all {}"
                ;;
            3)
                # push a specific branch to all remotes
                $GIT_BIN remote |
                    xargs -I {} sh -c "echo '>>> Pushing $BRANCH branch to {}...'; $GIT_BIN push {} $BRANCH"
                ;;
        esac
    else
        $GIT_BIN "$@"
    fi
}

,git-upstream-sync() {
    if git remote | grep -q upstream; then
        git fetch upstream
        git checkout master
        git merge upstream/master
        git push -u origin master
    else
        echo "remote 'upstream' is not set yet."
    fi
}
