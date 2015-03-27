FROM alpine
MAINTAINER "Guigo2k" <hello@guigo.pw>

ADD s6/* /
ADD np-cli /usr/local/np-cli
RUN /usr/local/np-cli/np setup

USER npuser
EXPOSE 80 443
ENTRYPOINT ["/usr/bin/np"]
CMD ["start"]
