# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit eutils games

DESCRIPTION="ctris is a colorized, small and flexible Tetris(TM)-clone for the console"
HOMEPAGE="http://www.hackl.dhs.org/ctris/"
SRC_URI="http://www.hackl.dhs.org/data/download/download.php?file=${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~mips ~sparc ~x86 ~amd64"
DEPEND="sys-libs/ncurses"

src_compile() {
	emake CFLAGS="${CFLAGS}" || die
}

src_install(){
	dogamesbin ctris || die
	doman ctris.6.gz || die
	prepgamesdirs
}