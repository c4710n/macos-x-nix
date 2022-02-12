## DOCKER ##
alias ,docker-try="docker run -it --rm"

alias ,docker-dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage"

,docker-cleanup-ic() {
    # exited containers
    docker ps --filter status=exited -q 2>/dev/null | xargs --no-run-if-empty docker rm -v
    # dead containers
    docker ps --filter status=dead -q 2>/dev/null | xargs --no-run-if-empty docker rm -f -v
    # dangling images
    docker images --filter dangling=true -q 2>/dev/null | xargs --no-run-if-empty docker rmi -f
    # dangling volumes
    docker volume ls --filter dangling=true -q 2>/dev/null  | xargs --no-run-if-empty docker volume rm
}

,docker-rmc-by-name() {
    docker ps -a | grep "$1" | awk '{ print $1 }' | xargs --no-run-if-empty docker rm
}

,docker-rmi-by-regexp() {
    REGEXP="$1"
    DRY="$2"

    if [ -z "$REGEXP" ]; then
        echo 'Error: no regexp specified.'
    elif [ -n "$REGEXP" ] && [ -n "$DRY" ]; then
        docker images | grep -v 'REPOSITORY' | awk '{print $1":"$2}' | grep -E "$REGEXP"
    else
        docker images | grep -v 'REPOSITORY' | awk '{print $1":"$2}' | grep -E "$REGEXP" | xargs --no-run-if-empty docker rmi
    fi
}
