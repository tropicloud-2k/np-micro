FROM gliderlabs/alpine:3.1
MAINTAINER "Guigo2k" <hello@guigo.pw>

ADD s6/* /
ADD nps /usr/local/nps

RUN /bin/sh /usr/local/nps/nps setup

EXPOSE 80 443
ENTRYPOINT ["/usr/bin/nps"]
CMD ["start"]
