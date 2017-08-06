# Created by: Toni Schmidbauer <toni@stderr.at>
# $FreeBSD$

PORTNAME=	crystal
PORTVERSION=	0.23.1
PORTEPOCH=	1
CATEGORIES=	lang
MASTER_SITES=	http://golang.org/dl/
DISTNAME=	crystal-${PORTVERSION}

COMMENT=	Crystal programming language

LICENSE=	APACHE

BUILD_DEPENDS=	shells/bash 
                # go14>=1.4:lang/go14

LIB_DEPENDS =  converters/libiconv \
               devel/boehm-gc \
               devel/libevent2 \
               devel/pcre

USES=		shebangfix
SHEBANG_LANG=	bash
SHEBANG_FILES=	src/*.bash \
		doc/articles/wiki/*.bash \
		lib/time/*.bash \
		misc/benchcmp \
		misc/nacl/go_nacl_*_exec \
		src/cmd/dist/*.bash \
		src/cmd/go/*.sh \
		src/net/http/cgi/testdata/*.cgi \
		src/regexp/syntax/*.pl

sh_OLD_CMD=	"/usr/bin/env bash"
sh_CMD=		${SH}

WRKSRC=		${WRKDIR}/crystal

ONLY_FOR_ARCHS=	i386 amd64 

.include <bsd.port.pre.mk>

PLIST_SUB+=	opsys_ARCH=${OPSYS:tl}_${GOARCH}

post-patch:
	@cd ${WRKSRC} && ${FIND} . -name '*.orig' -delete

do-build:
        clang++ -c -o ${WRKSRC}/src/llvm/ext/llvm_ext.o ${WRKSRC}/src/llvm/ext/llvm_ext.cc `llvm-config --cxxflags` 
	clang -c -o ${WRKSRC}/src/ext/sigfault.o ${WRKSRC}/src/ext/sigfault.c `llvm-config --cflags`

	mkdir ${WRKSRC}/.build
	cp ../crystal ${WRKSRC}/.build/

        cd ${WRKSRC} && gmake deps && CC=clang gmake

do-install:
	@${CP} -a ${WRKSRC} ${STAGEDIR}${PREFIX}
.for f in go gofmt
	@${LN} -sf ../go/bin/${f} ${STAGEDIR}${PREFIX}/bin/${f}
.endfor

regression-test: build
	cd ${WRKSRC}/src && GOROOT=${WRKSRC} PATH=${WRKSRC}/bin:${PATH} ${SH} run.bash --no-rebuild --banner


.include <bsd.port.post.mk>
