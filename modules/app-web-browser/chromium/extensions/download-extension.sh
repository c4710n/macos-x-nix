#!/usr/bin/env bash

## After downloading all the extensions, read following link learn about how to install:
#
#    https://ungoogled-software.github.io/ungoogled-chromium-wiki/faq#installing-the-crx-file
#
download-extension() {
    VERSION="95"
    EXTENSION_ID=$1
    EXTENSION_NAME=$2
    FILE_NAME="${EXTENSION_NAME}.crx"


    echo -n "$EXTENSION_NAME... "
    if [ -f "${FILE_NAME}" ]; then
        echo "exist"
    else
        curl -sSL \
             "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&prodversion=${VERSION}&x=id%3D${EXTENSION_ID}%26installsource%3Dondemand%26uc" \
             -o "${EXTENSION_NAME}".crx

        echo "done"
    fi
}

download-extension cjpalhdlnbpafiamejdnhcphjbkeiagm 'uBlock Origin'
download-extension gcbommkclmclpchllfjekcdonpmejbdp 'HTTPS Everywhere'
download-extension lckanjgmijmafbedllaakclkaicjfmnk 'ClearURLs'
download-extension mpiodijhokgodhhofbcjdecpffjipkle 'SingleFile'
download-extension geddoclleiomckbhadiaipdggiiccfje 'Quick Javascript Switcher'
