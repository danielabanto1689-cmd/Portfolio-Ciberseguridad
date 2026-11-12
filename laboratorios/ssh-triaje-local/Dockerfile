FROM debian:bookworm-slim@sha256:734a72b3d6142a71993b4bc580ca01d8ca687f77a2c422d96a961d3376b179bc AS base

FROM base AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential ca-certificates curl zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN curl --fail --silent --show-error --location \
        https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.5p1.tar.gz \
        --output openssh-8.5p1.tar.gz \
    && echo 'f52f3f41d429aa9918e38cf200af225ccdd8e66f052da572870c89737646ec25  openssh-8.5p1.tar.gz' | sha256sum --check \
    && tar -xzf openssh-8.5p1.tar.gz

WORKDIR /src/openssh-8.5p1
RUN ./configure --without-openssl --with-privsep-path=/run/sshd \
    && make -j2 sshd ssh-keygen

FROM base

RUN apt-get update \
    && apt-get install -y --no-install-recommends passwd zlib1g \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --no-create-home --home-dir /run/sshd --shell /usr/sbin/nologin sshd \
    && useradd --create-home --shell /bin/sh labssh \
    && install -d -m 0755 /run/sshd /etc/ssh

COPY --from=build /src/openssh-8.5p1/sshd /usr/local/sbin/sshd
COPY --from=build /src/openssh-8.5p1/ssh-keygen /usr/local/bin/ssh-keygen
COPY sshd_config /etc/ssh/sshd_config
COPY start-sshd.sh /usr/local/bin/start-sshd.sh

CMD ["/bin/sh", "/usr/local/bin/start-sshd.sh"]
