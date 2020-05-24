# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils

DESCRIPTION="MJPG-streamer takes JPGs from Linux-UVC compatible webcams"
HOMEPAGE="https://github.com/jacksonliam/mjpg-streamer"
SRC_URI="https://haos.hopto.org/Stuff/${CATEGORY}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

INPUT_PLUGINS="input-testpicture input-control input-file input-uvc input-http input-opencv input-ptp2"
OUTPUT_PLUGINS="output-file output-udp output-http output-autofocus output-rtsp output-viewer output-zmqserver"
IUSE_PLUGINS="${INPUT_PLUGINS} ${OUTPUT_PLUGINS}"
IUSE="input-testpicture input-control +input-file input-uvc input-http input-opencv input-ptp2
	output-file	output-udp +output-http output-autofocus output-rtsp output-viewer output-zmqserver
	www http-management wxp-compat"
REQUIRED_USE="|| ( ${INPUT_PLUGINS} )
	|| ( ${OUTPUT_PLUGINS} )"

RDEPEND="virtual/jpeg
	input-uvc? ( media-libs/libv4l )
	input-opencv? ( media-libs/opencv )
	output-zmqserver? ( dev-libs/protobuf-c net-libs/zeromq )
	input-ptp2? ( media-libs/libgphoto2 )"
DEPEND="${RDEPEND}
	input-testpicture? ( media-gfx/imagemagick )"

S="${WORKDIR}/mjpg-streamer-experimental"

src_prepare() {
	sed -i -e "s|.*RPATH.*||g" CMakeLists.txt
	use wxp-compat && sed -i -e \
		's|^add_feature_option(WXP_COMPAT "Enable compatibility with WebcamXP" OFF)|add_feature_option(WXP_COMPAT "Enable compatibility with WebcamXP" ON)|g' CMakeLists.txt

	local flag switch
	for flag in ${IUSE_PLUGINS}; do
		use ${flag} && switch='' || switch='#'
		flag=${flag/input-/input_}
		flag=${flag/output-/output_}
		sed -i -e \
			"s|^add_subdirectory(plugins\/${flag})|${switch}add_subdirectory(plugins/${flag})|" \
			CMakeLists.txt
	done
	use http-management && sed -i -e \
		's|^add_feature_option(ENABLE_HTTP_MANAGEMENT "Enable experimental HTTP management option" OFF)|add_feature_option(ENABLE_HTTP_MANAGEMENT "Enable experimental HTTP management option" ON)|g' plugins/output_http/CMakeLists.txt

	default
}

#src_compile() {
#	local v4l=$(use input-uvc && echo 'USE_LIBV4L2=true')
#	local management=$(use http-management && echo 'ENABLE_HTTP_MANAGEMENT=true')
#	emake ${v4l} ${management}
#}

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

	sed -e "s|@LIBDIR@|$(get_libdir)/${PN}/$(get_libdir)|g" "${FILESDIR}/${PN}.initd" | newinitd - ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
}

pkg_postinst() {
	elog "Remember to set an input and output plugin for mjpg-streamer."

	if use www ; then
		echo
		elog "An example webinterface has been installed into"
		elog "/usr/share/mjpg-streamer/www for your usage."
	fi
}
