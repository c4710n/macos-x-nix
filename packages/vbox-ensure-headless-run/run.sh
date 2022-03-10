#!/usr/bin/env bash

# VirtualBox is managed by homebrew, and the PATH is /usr/local/bin
export PATH=/usr/local/bin:$PATH

VM_MANAGER_CMD=VBoxManage

if ! command -v ${VM_MANAGER_CMD} &> /dev/null; then
    echo "[error] ${VM_MANAGER_CMD} not found"
    exit 1
fi

VM_NAME=$1

found_vm=$(${VM_MANAGER_CMD} list vms | grep -c "\"${VM_NAME}\"")
if [ $((found_vm)) -ne 1 ]; then
    echo "[$VM_NAME] virtual machine not found"
    exit 1
fi

running_vm=$(${VM_MANAGER_CMD} list runningvms | grep -c "\"${VM_NAME}\"")
if [ $((running_vm)) -eq 1 ]; then
    echo "[$VM_NAME] virtual machine is running"
    exit 1
fi

echo "[${VM_NAME}] starting..."
${VM_MANAGER_CMD} startvm ${VM_NAME} --type headless
