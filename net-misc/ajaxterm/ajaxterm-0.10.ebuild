# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit python-single-r1

MY_P="Ajaxterm-${PV}"

DESCRIPTION="Ajaxterm is a web based terminal"
HOMEPAGE="http://antony.lesuisse.org/qweb/trac/wiki/AjaxTerm"
SRC_URI="https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/ajaxterm/0.10-12ubuntu1/ajaxterm_${PV}.orig.tar.gz"

LICENSE="public-domain LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~sparc ~x86"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND=""
DEPEND=""

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	# baselayout's start-stop-daemon wrapper does not allow shell scripts
	sed -i -e "s: -- :\0/usr/share/ajaxterm/ajaxterm.py :" \
		-e "s:\(DAEMON=%(bin)s/\)ajaxterm:\1python:" \
		-e "s:\#\!/sbin/runscript:\#\!/sbin/openrc-run:" \
		configure.initd.gentoo

	eapply_user
}

src_configure() {
	./configure --prefix=/usr || die "./configure failed"
}

src_install() {
	dodir /etc/init.d
	sed -i -e "s:\"/usr:\"${D}/usr:" \
		-e "s:\"/etc:\"${D}/etc:" \
		-e "s:/usr/man:/usr/share/man:" Makefile
	emake install || die "emake install failed"
}

pkg_postinst() {
	ewarn "For remote access, it is strongly recommended to use https SSL/TLS"
	ewarn "On the website is a config for apache web server using mod_proxy"
}
