ARG project

FROM --platform=$BUILDPLATFORM debian:bullseye AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM

WORKDIR /home/

COPY ./ ./build

RUN apt update && \
    apt install -y --no-install-recommends wget ca-certificates unzip gcc && \
    cd build && \
    wget https://xmake.io/shget.text -O getxmake.sh && \
    bash getxmake.sh && \
    XMAKE_ROOT=y ~/.local/bin/xmake config -y --arch=$TARGETPLATFORM --mode=release --ldflags="-static" && \
    XMAKE_ROOT=y ~/.local/bin/xmake -y && \
    INSTALLDIR=/usr/local/ XMAKE_ROOT=y ~/.local/bin/xmake install -y && \
    cd .. && rm -Rf ./build && rm -Rf ~/.local/* && \
    apt remove -y wget ca-certificates unzip gcc && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/*


FROM scratch AS skyrim
WORKDIR /
COPY --from=builder /usr/local/bin/SkyrimTogetherServer /SkyrimTogetherServer
ENTRYPOINT ["/SkyrimTogetherServer"]

FROM scratch AS fallout4
WORKDIR /
COPY --from=builder /usr/local/bin/FalloutTogetherServer /FalloutTogetherServer
ENTRYPOINT ["/FalloutTogetherServer"]

FROM ${project} AS final

FROM final
EXPOSE 10578/udp
