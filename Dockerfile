# Build lighttpd
FROM alpine:latest as buildenv
WORKDIR /root

RUN apk add --no-cache autoconf automake build-base curl libtool libxml2-dev pcre2-dev sqlite-dev util-linux-dev

RUN VERSION=`curl -L https://download.lighttpd.net/lighttpd/releases-1.4.x/latest.txt` \
    && curl -L https://download.lighttpd.net/lighttpd/releases-1.4.x/$VERSION.tar.xz | tar -Jxf - \
    && mv $VERSION lighttpd-latest

WORKDIR /root/lighttpd-latest
RUN ./autogen.sh
RUN ./configure --prefix=/usr --libdir=/usr/lib/lighttpd --with-sqlite --with-webdav-locks --with-webdav-props
RUN make install -j8


# Build the real container
FROM alpine:latest

RUN apk add --no-cache libgcc libxml2 pcre2 shadow sqlite-dev util-linux
RUN adduser -S -H -D -u 1000 -s /sbin/nologin www-data

COPY --from=buildenv /usr/lib/lighttpd /usr/lib/lighttpd
COPY --from=buildenv /usr/sbin/lighttpd /usr/sbin/lighttpd

COPY ./files/lighttpd.conf /etc/lighttpd.conf
RUN mkdir /var/lighttpd \
    && chown www-data /var/lighttpd

USER www-data
EXPOSE 8080
CMD ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd.conf"]
