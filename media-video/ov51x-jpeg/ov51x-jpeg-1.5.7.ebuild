# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod

DESCRIPTION="OV51x driver for Linux which supports JPEG decompression inside the kernel"
HOMEPAGE="http://www.rastageeks.org/ov51x-jpeg/index.php/Main_Page"
SRC_URI="http://www.rastageeks.org/downloads/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

CONFIG_CHECK="USB VIDEO_V4L1_COMPAT"
ERROR_USB="${P} requires Host-side USB support (CONFIG_USB)."
ERROR_VIDEO_V4L1_COMPAT="${P} require support for the Video For Linux API 1 compatibility layer (CONFIG_VIDEO_V4L1_COMPAT)."
MODULE_NAMES="ov51x-jpeg(media/video:)"
BUILD_TARGETS="all"
BUILD_PARAMS="KERNELDIR=${KV_DIR}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/ov51x-jpeg-core.patch || die

	convert_to_m "${S}"/Makefile
}

src_install() {
	linux-mod_src_install
	dodoc ChangeLog || die "dodoc failed"
}
