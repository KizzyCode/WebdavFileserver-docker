FROM debian:latest

ENV DEBIAN_FRONTEND noninteractive
ENV PACKAGES lighttpd lighttpd-mod-webdav
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${PACKAGES} \
    && apt-get autoremove --yes

RUN usermod --uid=1000 www-data

ARG LIGHTTPD_CONFIG=./files/lighttpd.conf
COPY ${LIGHTTPD_CONFIG} /etc/lighttpd.conf
RUN mkdir /var/lighttpd \
    && chown www-data /var/lighttpd

USER www-data
EXPOSE 8080
CMD ["/usr/sbin/lighttpd", "-D", "-f", "/etc/lighttpd.conf"]
