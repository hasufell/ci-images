FROM alpine:3.12.0
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
# Installing GHC build dependencies
RUN apk add --no-cache autoconf automake binutils-gold build-base coreutils cpio linux-headers libffi-dev musl-dev ncurses-dev ncurses-static python3 zlib-dev xz bash git wget sudo grep curl gmp-dev cabal py3-sphinx texlive texlive-xetex texmf-dist-latexextra ttf-dejavu

ENV GHC /opt/ghc/8.10.7/bin/ghc
ENV CABAL /usr/bin/cabal

# fetch GHC
RUN curl -L https://downloads.haskell.org/~ghc/8.10.7/ghc-8.10.7-x86_64-alpine3.10-linux-integer-simple.tar.xz > /tmp/ghc.tar.xz && \
	tar -C /tmp -Jxf /tmp/ghc.tar.xz && \
	cd /tmp/ghc-8.10.7* && ./configure --disable-ld-override --prefix=/opt/ghc/8.10.7 && make install && \
	cd && \
	rm -Rf /tmp/ghc-8.10.7-* && \
	rm -f /tmp/ghc.tar.xz && \
	/opt/ghc/8.10.7/bin/ghc --version && \
	mkdir -p /opt/toolchain/store && $CABAL user-config update && $CABAL v2-update && $CABAL \
	  --store-dir=/opt/toolchain/store \
	  v2-install \
	  --constraint='alex ^>= 3.2.6' \
	  --constraint='happy ^>= 1.20' \
	  --with-compiler=$GHC \
	  --enable-static \
	  --install-method=copy \
	  --installdir=/opt/toolchain/bin \
	  hscolour happy alex hlint-3.2

ENV ALEX /opt/toolchain/bin/alex
ENV HAPPY /opt/toolchain/bin/happy
ENV HLINT /opt/toolchain/bin/hlint
ENV HSCOLOUR /opt/toolchain/bin/HsColour
# create user
RUN adduser ghc --gecos 'GHC builds' --disabled-password && echo 'ghc ALL = NOPASSWD : ALL' > /etc/sudoers.d/ghc

USER ghc
WORKDIR /home/ghc/

CMD ["bash"]
