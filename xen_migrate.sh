#!/bin/bash

set -e #exit on errors
set -x #verbose

if [ $# -ne 2 ]; then
    echo "Usage: $0 domid dsthost"
    exit 1
fi

DOMID=$1
DSTHOST=$2
FILES=$(xen_vbds.py $DOMID)

check_running() {
    #sort of redundant now, the call to xen_vbds will fail
    #earlier if the domain is not running.
    xm list ${DOMID}
}

sync_disk() {
    for f in $FILES;do
        case $f in
            /dev/*)
                blocksync.py ${f} ${DSTHOST}
                ;;
            *)
                rsync -avPS ${f} ${DSTHOST}:${f}
                ;;
        esac
    done
}

save_image() {
    xm save ${DOMID} ${DOMID}.dump
}
copy_image() {
    scp -C ${DOMID}.dump ${DSTHOST}:
}
restore_image() {
    ssh ${DSTHOST} "xm restore ${DOMID}.dump && rm ${DOMID}.dump"
    rm ${DOMID}.dump
}

main() {
    check_running
    sync_disk
    save_image
    sync_disk
    copy_image
    restore_image
}


main
