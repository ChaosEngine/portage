# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit cmake-utils

DESCRIPTION="QGifer"
HOMEPAGE="https://sourceforge.net/projects/qgifer/"
#SRC_URI="http://dev.gentoo.org/~aidecoe/distfiles/${CATEGORY}/${PN}/${P}.zip"
SRC_URI="mirror://sourceforge/${PN}/${P}-source.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="media-libs/giflib
	dev-qt/qtcore:4
	media-libs/opencv"
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.8"

S=${WORKDIR}/${P}-source/

src_prepare() {
	epatch "${FILESDIR}/${P}_desktop.patch"
}
