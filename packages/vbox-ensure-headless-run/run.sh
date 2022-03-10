#!/usr/bin/env bash

# VirtualBox is managed by homebrew, and the PATH is /usr/local/bin
export PATH=/usr/local/bin:$PATH

VM_MANAGER_CMD=VBoxManage

function log() {
    content=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') $content"
}

if [ "$(id -u)" != "0" ]; then
    log "root permission is required." 1>&2
    exit 1
fi

if ! command -v ${VM_MANAGER_CMD} &> /dev/null; then
    log "[error] ${VM_MANAGER_CMD} not found"
    exit 1
fi

USERNAME=$1
VM_NAME=$2

found_vm=$(su ${USERNAME} -c -- "${VM_MANAGER_CMD} list vms | grep -c '\"${VM_NAME}\"'")
if [ $((found_vm)) -ne 1 ]; then
    log "[$VM_NAME] virtual machine not found"
    exit 1
fi

running_vm=$(su ${USERNAME} -c -- "${VM_MANAGER_CMD} list runningvms | grep -c '\"${VM_NAME}\"'")
if [ $((running_vm)) -eq 1 ]; then
    log "[$VM_NAME] virtual machine is running"
    exit 1
fi

log "[${VM_NAME}] starting..."
su ${USERNAME} -c -- "${VM_MANAGER_CMD} startvm ${VM_NAME} --type headless"
