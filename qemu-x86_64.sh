#!/bin/bash

BUSYBOX=../../busybox-1.36.0/       
INITRD=${PWD}/initramfs.cpio.gz
BUSYBOX_INSTALL_DIR=$BUSYBOX/_install

if [ ! -f "$BUSYBOX_INSTALL_DIR/init" ]; then
  cd $BUSYBOX && make install && cd - 
fi

cat <<EOF > $BUSYBOX_INSTALL_DIR/init
#!/bin/busybox sh

/bin/busybox mkdir -p /proc && /bin/busybox mount -t proc none /proc

/bin/busybox echo -e "\033[33m[$(date)] Hello, Welcome to Rust for Linux! \033[0m"

export 'PS1=(kernel) >'
/bin/busybox sh
EOF

chmod +x $BUSYBOX_INSTALL_DIR/init

cd $BUSYBOX_INSTALL_DIR && find . -print0 | cpio --null -ov --format=newc | gzip -9 > ${INITRD} && cd -

qemu-system-x86_64 \
  -kernel ./build/arch/x86_64/boot/bzImage \
  -initrd ${INITRD} \
  -smp 2 \
  -m 128M \
  -nographic \
  -append 'init=/init console=ttyS0'
