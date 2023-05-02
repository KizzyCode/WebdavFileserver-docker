FROM alpine:latest

RUN apk add --no-cache lighttpd lighttpd-mod_webdav lighttpd-mod_auth shadow
RUN adduser -S -H -D -u 1000 -s /sbin/nologin www-data

COPY ./files/lighttpd.conf /etc/lighttpd.conf
RUN mkdir /var/lighttpd \
    && chown www-data /var/lighttpd

USER www-data
EXPOSE 8080
CMD ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd.conf"]
