FROM gliderlabs/alpine:3.1
MAINTAINER "Guigo2k" <hello@guigo.pw>

ADD root /
RUN /usr/local/np-cli/np setup

EXPOSE 80 443
ENTRYPOINT ["/usr/bin/np"]
CMD ["start"]
