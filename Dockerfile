FROM alpine:latest

ENV DEHYDRATED_VERSION 0.6.5

ADD https://github.com/lukas2511/dehydrated/releases/download/v${DEHYDRATED_VERSION}/dehydrated-${DEHYDRATED_VERSION}.tar.gz /dehydrated.tar.gz
ADD https://github.com/lukas2511/dehydrated/releases/download/v${DEHYDRATED_VERSION}/dehydrated-${DEHYDRATED_VERSION}.tar.gz.asc /dehydrated.tar.gz.asc


RUN GPG_KEYS=3C2F2605E078A1E18F4793909C4DBE6CF438F333 \
	&& set -xe \
	&& addgroup -S dehydrated \
	&& adduser -S -D -H -s /sbin/nologin -G dehydrated dehydrated \
	&& echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
	&& apk update \
	&& apk add --no-cache --virtual .build-deps \
		gnupg \
	&& apk add --no-cache --virtual .run-deps \
		su-exec \
		bash \
		openssl \
		curl \
		coreutils \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& found=''; \
	for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $GPG_KEYS from $server"; \
		gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
	gpg --batch --verify dehydrated.tar.gz.asc dehydrated.tar.gz \
	&& rm -rf "$GNUPGHOME" dehydrated.tar.gz.asc \
	&& mkdir /opt/dehydrated \
    && tar -zxC /opt/dehydrated -f dehydrated.tar.gz --strip 1 \
    && rm dehydrated.tar.gz \
	&& apk del .build-deps

COPY ./container-data /

ENTRYPOINT ["/docker-entrypoint.sh"]