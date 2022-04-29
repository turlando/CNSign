FROM alpine:3.15 AS builder

WORKDIR /source

RUN apk add --update --no-cache \
    curl                        \
    tar                         \
    gcc                         \
    make                        \
    pkgconf                     \
    openssl3-dev                \
    libc-dev

RUN curl -L -O                                                                            \
    https://github.com/OpenSC/libp11/releases/download/libp11-0.4.11/libp11-0.4.11.tar.gz \
    &&                                                                                    \
    tar xvf libp11-0.4.11.tar.gz                                                          \
    &&                                                                                    \
    cd libp11-0.4.11                                                                      \
    &&                                                                                    \
    mkdir /build                                                                          \
    &&                                                                                    \
    ./configure --prefix=/usr                                                             \
    &&                                                                                    \
    make                                                                                  \
    &&                                                                                    \
    make DESTDIR=/build install

################################################################################

FROM alpine:3.15

WORKDIR /app

RUN apk add --update --no-cache \
    make                        \
    openssl3                    \
    opensc                      \
    pcsc-lite-libs              \
    ccid

COPY --from=builder /build /

COPY openssl.cnf  /app/openssl.cnf
COPY Makefile.app /app/Makefile

CMD pcscd \
    &&    \
    sh
