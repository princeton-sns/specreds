#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "usage: ./launch-vm.sh [cores] [memory in GB] [path to boot disk image]"
    exit 1
fi

sudo qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -smp $1 \
    -m $2G \
    -device virtio-scsi-pci,id=scsi0 \
    -device scsi-hd,drive=hd0,id=disk0 \
    -drive file=$3,if=none,aio=native,cache=none,format=qcow2,id=hd0 \
    -net user,hostfwd=tcp::8080-:22 \
    -net nic,model=virtio \
    -daemonize \
    -qmp unix:./qmp.sock,server,nowait \
    -vnc localhost:0

