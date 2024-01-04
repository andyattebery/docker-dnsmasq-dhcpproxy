FROM alpine:latest

RUN apk upgrade && \
    apk add --no-cache dnsmasq

COPY entrypoint.sh /entrypoint.sh

EXPOSE 67/udp 
#68/tcp 68/udp

VOLUME /etc/dnsmasq.d

ENTRYPOINT ["/entrypoint.sh"]
CMD ["dnsmasq", "--keep-in-foreground", "--log-queries"]