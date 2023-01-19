#!/bin/bash -e

on_chroot <<EOF
for GRP in video input render; do
  adduser $FIRST_USER_NAME \$GRP
done
EOF

on_chroot << EOF
  SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_boot_behaviour B2
EOF

install -m 644 files/backlight.rules 		"${ROOTFS_DIR}/etc/udev/rules.d/"

install -m 644 files/dt-blob.bin 		"${ROOTFS_DIR}/boot/"
install -m 644 files/*.dtbo 			"${ROOTFS_DIR}/boot/overlays/"

install -m 755 files/cutoff 			"${ROOTFS_DIR}/usr/lib/systemd/system-shutdown/"
install -m 755 files/cutiepi-mcuproxy 		"${ROOTFS_DIR}/usr/local/bin/"

cp files/*.deb					"${ROOTFS_DIR}/tmp"

on_chroot <<EOF
dpkg -i /tmp/*.deb
EOF



# Apply ts rotation matrix rule
tar xvpf files/ts-rotate-270-cw-udev-rule.tar.gz -C "${ROOTFS_DIR}/"

# Install shell
tar xvpf files/firoz_shell.tar.gz -C "${ROOTFS_DIR}/"

# Install connectivity manager
tar xvpf files/connectivity_manager.tar.gz -C "${ROOTFS_DIR}/"

# Install cloud connect
tar xvpf files/cloud_connect.tar.gz -C "${ROOTFS_DIR}/"


tar xvpf files/panel-config.tgz -C 		"${ROOTFS_DIR}/home/${FIRST_USER_NAME}/"
tar xvpf files/dconf-config.tgz -C 		"${ROOTFS_DIR}/home/${FIRST_USER_NAME}/"

rm -f "${ROOTFS_DIR}/etc/wpa_supplicant/wpa_supplicant.conf"

sed -i 's/console=serial0,115200 //'		"${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's/quiet //'				"${ROOTFS_DIR}/boot/cmdline.txt"
sed -i 's/splash //'				"${ROOTFS_DIR}/boot/cmdline.txt"

# Uncomment to get 10 inch display drivers loaded
tar xvpf files/panel-10inch-ilitek-ili9881c-1.0.tgz -C "${ROOTFS_DIR}/"
on_chroot <<EOF
dkms add -m panel-ilitek-ili9881c/1.0
dkms build -m panel-ilitek-ili9881c -v 1.0 -k 5.15.84-v8+
dkms install -m panel-ilitek-ili9881c -v 1.0 -k 5.15.84-v8+
EOF

# Disables hdmi on rpi
tar xvf files/vc4-1.0.tgz -C "${ROOTFS_DIR}/"
on_chroot <<EOF
dkms add -m vc4/1.0
dkms install -m vc4/1.0 -k 5.15.84-v8+
cat "${ROOTFS_DIR}/var/lib/dkms/vc4/1.0/build/make.log"
EOF



on_chroot << EOF
systemctl enable firoz.shell.service
systemctl enable firoz.connectivity.manager.service
systemctl enable firoz.cloud.connect.service
EOF
