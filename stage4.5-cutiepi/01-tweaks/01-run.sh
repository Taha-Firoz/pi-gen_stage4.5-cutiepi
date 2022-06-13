#!/bin/bash -e

on_chroot <<EOF
for GRP in video input render; do
  adduser $FIRST_USER_NAME \$GRP
done
EOF

install -m 644 files/backlight.rules 		"${ROOTFS_DIR}/etc/udev/rules.d/"

install -m 644 files/dt-blob.bin 		"${ROOTFS_DIR}/boot/"
install -m 644 files/*.dtbo 			"${ROOTFS_DIR}/boot/overlays/"

install -m 755 files/cutoff 			"${ROOTFS_DIR}/usr/lib/systemd/system-shutdown/"
install -m 755 files/cutiepi-mcuproxy 		"${ROOTFS_DIR}/usr/local/bin/"

tar xvpf files/panel-config.tgz -C 		"${ROOTFS_DIR}/home/${FIRST_USER_NAME}/"
tar xvpf files/dconf-config.tgz -C 		"${ROOTFS_DIR}/home/${FIRST_USER_NAME}/"

rm -f "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"

sed -i 's/console=serial0,115200 //'		"${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's/quiet //'				"${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's/splash //'				"${ROOTFS_DIR}/boot/cmdline.txt"

tar xvpf files/panel-10inch-ilitek-ili9881c-1.0.tgz -C "${ROOTFS_DIR}/"
on_chroot <<EOF
dkms add -m panel-ilitek-ili9881c/1.0
dkms build -m panel-ilitek-ili9881c -v 1.0
dkms install -m panel-ilitek-ili9881c -v 1.0
EOF
