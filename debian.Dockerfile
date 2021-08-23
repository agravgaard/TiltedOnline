FROM debian:bullseye

ARG project

WORKDIR /home/

COPY ./ ./build

RUN apt update && \
    apt install -y --no-install-recommends wget ca-certificates unzip gcc && \
    cd build && \
    wget https://xmake.io/shget.text -O getxmake.sh && \
    bash getxmake.sh && \
    XMAKE_ROOT=y ~/.local/bin/xmake config -y --mode=release ${project}TogetherServer && \
    XMAKE_ROOT=y ~/.local/bin/xmake -y && \
    INSTALLDIR=/usr/local/ XMAKE_ROOT=y ~/.local/bin/xmake install -y && \
    cd .. && rm -Rf ./build && rm -Rf ~/.local/* && \
    apt remove -y wget ca-certificates unzip gcc && \
    apt autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/local/bin/${project}TogetherServer"]

EXPOSE 10578/udp
