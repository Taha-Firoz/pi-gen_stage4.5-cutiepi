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

# Install shell
# install -m 444 files/firoz.shell.service 			"${ROOTFS_DIR}/etc/systemd/system"
# tar xvpf files/firoz_shell.tar.gz -C "${ROOTFS_DIR}/"

# Install connectivity manager
install -m 444 files/com.Firoz.Connectivity.Manager.conf 			"${ROOTFS_DIR}/etc/dbus-1/system.d"
install -m 444 files/firoz.connectivity.manager.service 			"${ROOTFS_DIR}/etc/systemd/system"
tar xvpf files/connection_manager.tar.gz -C "${ROOTFS_DIR}/"

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
dkms build -m panel-ilitek-ili9881c -v 1.0 -k 5.15.56-v8+
dkms install -m panel-ilitek-ili9881c -v 1.0 -k 5.15.56-v8+
EOF


# # Disables hdmi on rpi
tar xvf files/5.15.56-vc4-1.0.tgz -C "${ROOTFS_DIR}/"
on_chroot <<EOF
dkms add -m vc4/1.0
dkms install -m vc4/1.0 -k 5.15.56-v8+
EOF



# on_chroot << EOF
# systemctl enable firoz.shell.service
# systemctl enable firoz.connectivity.manager.service
# EOF
