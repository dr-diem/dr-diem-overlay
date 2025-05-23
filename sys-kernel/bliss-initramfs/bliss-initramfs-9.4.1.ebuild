# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{6..13} )
inherit python-single-r1

DESCRIPTION="Boot your system's rootfs from Encrypted/OpenZFS."
HOMEPAGE="https://github.com/dr-diem/bliss-initramfs"
SRC_URI="https://github.com/dr-diem/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="strip"
LICENSE="Simplified-BSD"
SLOT="0"
KEYWORDS="-* amd64"

RDEPEND="
	${PYTHON_DEPS}
	app-arch/cpio
	virtual/udev"

S="${WORKDIR}/${PN}-${PV}"

CONFIG_FILE="/etc/bliss-initramfs/settings.json"

src_install() {
	# Copy the main executable
	local executable="mkinitrd.py"
	exeinto "/opt/${PN}"
	doexe "${executable}"

	# Copy the libraries required by this executable
	cp -r "${S}/files" "${D}/opt/${PN}" || die
	cp -r "${S}/pkg" "${D}/opt/${PN}" || die

	# Copy documentation files
	dodoc README.md README-MORE.md USAGE.md

	# Copy the configuration file for the user
	dodir "/etc/${PN}"
	cp "${S}/files/default-settings.json" "${D}${CONFIG_FILE}"

	# Make a relative symbolic link: /sbin/bliss-initramfs
	dosym "../opt/${PN}/${executable}" "/sbin/${PN}"
}

pkg_postinst() {
	elog "Version >=9.0.0 is a BREAKING CHANGE! bliss-initramfs now has native"
	elog "zfs encryption support, and LUKS has been completely removed. If you"
	elog "are using LUKS, please stay on version 8.1.0 since that is the last"
	elog "version to support LUKS!\n"
	elog "For a full list of changes, please read the release info located here:"
	elog "https://github.com/fearedbliss/bliss-initramfs/releases/tag/9.0.0"
	elog ""
	elog "As of version 8.1.0, ${PN} has a new centralized configuration architecture."
	elog "Any customizations you want to provide to ${PN} should be done by modifying"
	elog "${CONFIG_FILE}. You can use the \"-c/--config\" option to provide"
	elog "an alternate configuration path.\n"
	elog "For a full list of changes, please read the release info located here:"
	elog "https://github.com/fearedbliss/bliss-initramfs/releases/tag/8.1.0"
}
