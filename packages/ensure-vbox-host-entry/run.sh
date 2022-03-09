#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
    echo "root permission is required." 1>&2
    exit 1
fi

# VBoxManage is managed by homebrew, and the PATH is /usr/local/bin
export PATH=/usr/local/bin:$PATH

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
    su ${USERNAME} -c -- "VBoxManage guestproperty get ${VM_NAME} '/VirtualBox/GuestInfo/Net/${INTERFACE_NUM}/V4/IP' | awk '/^Value:/ { print \$2 }'"
}

function hostname-ensure-entry() {
    HOSTNAME=$1
    IP=$2

    HOST_FILE=/etc/hosts

    line_pattern="$IP[[:space:]]$HOSTNAME"
    line_content=$(printf "%s\t%s\n" "$IP" "$HOSTNAME")
    hostname_pattern="${HOSTNAME}$"

    matched_line=$(grep $line_pattern $HOST_FILE)
    matched_hostname=$(grep $hostname_pattern $HOST_FILE)

    if [ -z "$matched_line" ]; then
        if [ -n "$matched_hostname" ];then
            sed -i "/$hostname_pattern/d" /etc/hosts
        fi

        echo "[$HOSTNAME] ensure entry: $IP"
        echo "$line_content" >> $HOST_FILE;
    else
        echo "[$HOSTNAME] ensure entry: skip"
    fi

    matched_line=$(grep $line_pattern $HOST_FILE)
    if [ -z "$matched_line" ]; then
        echo "Fail to add $line_content";
    fi
}

USERNAME=$1
VM_NAME=$2
INTERFACE_NUM=$3

VM_IP=$(vbox-get-ip $USERNAME $VM_NAME $INTERFACE_NUM)

if [ -n "$VM_IP" ]; then
    echo "[$VM_NAME] find ip: $VM_IP"
    hostname-ensure-entry $VM_NAME $VM_IP
else
    echo "[$VM_NAME] find ip: missing"
fi