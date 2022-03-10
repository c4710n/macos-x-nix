#!/usr/bin/env bash

# VirtualBox is managed by homebrew, and the PATH is /usr/local/bin
export PATH=/usr/local/bin:$PATH

VM_MANAGER_CMD=VBoxManage

function vbox-get-ip() {
    USERNAME=$1
    VM_NAME=$2
    INTERFACE_NUM=$3

    # This command outputs something like this:
    #
    #   Value: 192.168.56.128
    #
    # Use awk match and get the IP.
    #
    # In case it fails, use following command for troubleshooting, since it lists all guest VM properties:
    #
    #   VBoxManage guestproperty enumerate $VM_NAME
    #
    su ${USERNAME} -c -- "${VM_MANAGER_CMD} guestproperty get ${VM_NAME} '/VirtualBox/GuestInfo/Net/${INTERFACE_NUM}/V4/IP' | awk '/^Value:/ { print \$2 }'"
}

function hostname-ensure-entry() {
    HOSTNAME=$1
    IP=$2

    HOST_FILE=/etc/hosts

    line_pattern="${IP}[[:space:]]${HOSTNAME}$"
    line_content=$(printf "%s\t%s\n" "$IP" "$HOSTNAME")
    hostname_pattern="${HOSTNAME}\$"

    matched_hosts=$(grep -c $hostname_pattern $HOST_FILE)
    if [ $((matched_hosts)) -ne 1 ]; then
        sed -i "/$hostname_pattern/d" /etc/hosts

        log "[$HOSTNAME] ensure entry: $IP"
        echo "$line_content" >> $HOST_FILE;
    else
        log "[$HOSTNAME] ensure entry: skip"
    fi

    matched_lines=$(grep -c $line_pattern $HOST_FILE)
    if [ $((matched_lines)) -eq 0 ]; then
        log "[$HOSTNAME] Fail to add $line_content";
    fi
}

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
INTERFACE_NUM=$3

found_vm=$(su ${USERNAME} -c -- "${VM_MANAGER_CMD} list vms | grep -c '\"${VM_NAME}\"'")
if [ $((found_vm)) -ne 1 ]; then
    log "[$VM_NAME] virtual machine not found"
    exit 1
fi

vm_ip=$(vbox-get-ip $USERNAME $VM_NAME $INTERFACE_NUM)
if [ -n "$vm_ip" ]; then
    log "[$VM_NAME] find ip: $vm_ip"
    hostname-ensure-entry $VM_NAME $vm_ip
else
    log "[$VM_NAME] find ip: missing"
fi
