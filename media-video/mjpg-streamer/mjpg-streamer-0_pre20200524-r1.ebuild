# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd

DESCRIPTION="MJPG-streamer takes JPGs from Linux-UVC compatible webcams"
HOMEPAGE="https://github.com/jacksonliam/mjpg-streamer"
EGIT_COMMIT="85f89a8c321e799fabb1693c5d133f3fb48ee748"
SRC_URI="https://github.com/jacksonliam/${PN}/archive/${EGIT_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

INPUT_PLUGINS="input-testpicture input-control input-file input-uvc input-http input-ptp2"
OUTPUT_PLUGINS="output-file output-udp output-http output-autofocus output-rtsp output-viewer output-zmqserver"
IUSE_PLUGINS="${INPUT_PLUGINS} ${OUTPUT_PLUGINS}"
IUSE="input-testpicture input-control +input-file input-uvc input-http input-ptp2
	output-file	output-udp +output-http output-autofocus output-rtsp output-viewer output-zmqserver
	www http-management wxp-compat"
REQUIRED_USE="|| ( ${INPUT_PLUGINS} )
	|| ( ${OUTPUT_PLUGINS} )"

RDEPEND="virtual/jpeg
	input-uvc? ( media-libs/libv4l )
	input-ptp2? ( media-libs/libgphoto2 )
	output-zmqserver? (
		dev-libs/protobuf-c
		net-libs/zeromq
	)"
DEPEND="${RDEPEND}
	input-testpicture? ( media-gfx/imagemagick )"

S="${WORKDIR}/${PN}-${EGIT_COMMIT}/${PN}-experimental"

src_prepare() {
	sed -i -e "s|.*RPATH.*||g" CMakeLists.txt || die
	if use wxp-compat; then
		sed -i -e \
			's|^add_feature_option(WXP_COMPAT "Enable compatibility with WebcamXP" OFF)|add_feature_option(WXP_COMPAT "Enable compatibility with WebcamXP" ON)|g' \
			CMakeLists.txt || die
	fi

	local flag switch
	for flag in ${IUSE_PLUGINS}; do
		use ${flag} && switch='' || switch='#'
		flag=${flag/input-/input_}
		flag=${flag/output-/output_}
		sed -i -e \
			"s|^add_subdirectory(plugins\/${flag})|${switch}add_subdirectory(plugins/${flag})|" \
			CMakeLists.txt || die
	done
	if use http-management; then
		sed -i -e \
		's|^add_feature_option(ENABLE_HTTP_MANAGEMENT "Enable experimental HTTP management option" OFF)|add_feature_option(ENABLE_HTTP_MANAGEMENT "Enable experimental HTTP management option" ON)|g' \
		plugins/output_http/CMakeLists.txt || die
	fi
	sed -e "s|@LIBDIR@|$(get_libdir)/${PN}/$(get_libdir)|g" "${FILESDIR}/${PN}.initd" > ${PN}.initd || die

	default
}

src_install() {
	into /usr
	dobin ${PN//-/_}
	into "/usr/$(get_libdir)/${PN}"
	dolib.so *.so

	if use www ; then
		insinto /usr/share/${PN}
		doins -r www
	fi

	dodoc README.md TODO

	newinitd ${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	systemd_dounit mjpg_streamer@.service
}

pkg_postinst() {
	elog "Remember to set an input and output plugin for mjpg-streamer."

	if use www ; then
		echo
		elog "An example webinterface has been installed into"
		elog "/usr/share/mjpg-streamer/www for your usage."
	fi
}
