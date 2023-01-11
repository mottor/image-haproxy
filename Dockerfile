#ARG HAPROXY_ORIG_VERSION=2.7.1-alpine3.17

#FROM haproxy:$HAPROXY_ORIG_VERSION
FROM alpine:3.17

ENV HAPROXY_BRANCH 2.8
ENV HAPROXY_MINOR 2.8-dev0
ENV HAPROXY_SHA256 7b01089e266604a262916a5d90a11b6a8520a023522a2cc8a4241696619f938d
ENV HAPROXY_SRC_URL http://www.haproxy.org/download

ENV HAPROXY_UID haproxy
ENV HAPROXY_GID haproxy

RUN apk add --no-cache --virtual build-deps ca-certificates gcc libc-dev \
    linux-headers lua5.3-dev make openssl openssl-dev pcre2-dev tar \
    zlib-dev curl shadow ca-certificates && \
    curl -sfSL "${HAPROXY_SRC_URL}/${HAPROXY_BRANCH}/src/devel/haproxy-${HAPROXY_MINOR}.tar.gz" -o haproxy.tar.gz && \
    echo "$HAPROXY_SHA256 *haproxy.tar.gz" | sha256sum -c - && \
    groupadd "$HAPROXY_GID" && \
    useradd -g "$HAPROXY_GID" "$HAPROXY_UID" && \
    mkdir -p /tmp/haproxy && \
    tar -xzf haproxy.tar.gz -C /tmp/haproxy --strip-components=1 && \
    rm -f haproxy.tar.gz && \
    make -C /tmp/haproxy -j"$(nproc)" TARGET=linux-musl CPU=generic USE_PCRE2=1 USE_PCRE2_JIT=1 USE_OPENSSL=1 \
                            USE_TFO=1 USE_LINUX_TPROXY=1 USE_GETADDRINFO=1 \
                            USE_LUA=1 LUA_LIB=/usr/lib/lua5.3 LUA_INC=/usr/include/lua5.3 \
                            USE_PROMEX=1 USE_SLZ=1 \
                            all && \
    make -C /tmp/haproxy TARGET=linux2628 install-bin install-man && \
    ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy && \
    mkdir -p /var/lib/haproxy && \
    mkdir -p /usr/local/etc/haproxy && \
    ln -s /usr/local/etc/haproxy /etc/haproxy && \
    cp -R /tmp/haproxy/examples/errorfiles /var/lib/haproxy/errors && \
    chown -R "$HAPROXY_UID:$HAPROXY_GID" /var/lib/haproxy && \
    chown -R "$HAPROXY_UID:$HAPROXY_GID" /usr/local/etc/haproxy && \
    rm -rf /tmp/haproxy && \
    apk del build-deps && \
    apk add --no-cache openssl zlib lua5.3-libs pcre2 jq socat util-linux bash && \
    rm -f /var/cache/apk/*

COPY scripts/ /opt/scripts
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY docker-entrypoint.sh /

STOPSIGNAL SIGUSR1

#HEALTHCHECK --interval=3s --timeout=3s --start-period=1s --retries=5 \
#  CMD wget -q --server-response --output-document - http://localhost/.haproxy/healthcheck | grep -q 'ALIVE' || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["haproxy", "-f", "/usr/local/etc/haproxy/haproxy.cfg"]


