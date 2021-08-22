ARG project
ARG arch

FROM debian:bullseye AS builder

WORKDIR /home/

COPY ./ ./build

RUN apt update && \
    apt install -y --no-install-recommends wget ca-certificates unzip gcc && \
    cd build && \
    wget https://xmake.io/shget.text -O getxmake.sh && \
    bash getxmake.sh && \
    XMAKE_ROOT=y ~/.local/bin/xmake config -y --arch=${arch} --mode=release && \
    XMAKE_ROOT=y ~/.local/bin/xmake -y && \
    INSTALLDIR=/usr/local/ XMAKE_ROOT=y ~/.local/bin/xmake install -y && \
    cd .. && rm -Rf ./build && rm -Rf ~/.local/* && \
    rm -rf /var/lib/apt/lists/*


FROM scratch AS skyrim
COPY --from=builder /usr/local/bin/SkyrimTogetherServer /SkyrimTogetherServer
ENTRYPOINT ["/SkyrimTogetherServer"]

FROM scratch AS fallout4
COPY --from=builder /usr/local/bin/FalloutTogetherServer /FalloutTogetherServer
ENTRYPOINT ["/FalloutTogetherServer"]

FROM ${project} AS final

FROM final
EXPOSE 10578/udp
