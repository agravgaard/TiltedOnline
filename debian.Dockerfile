ARG project=Skyrim

FROM debian:sid AS builder
ARG project

WORKDIR /home/
COPY ./ /home/build

RUN apt update && \
    apt install -y --no-install-recommends wget ca-certificates tar curl unzip && \
    wget https://xmake.io/shget.text -O getxmake.sh && \
    bash getxmake.sh && \
    cd build && \
    XMAKE_ROOT=y ~/.local/bin/xmake config -y --mode=release -v \
      ${project}TogetherServer && \
    XMAKE_ROOT=y ~/.local/bin/xmake -y ${project}TogetherServer && \
    INSTALLDIR=/usr/local/ XMAKE_ROOT=y ~/.local/bin/xmake install -y ${project}TogetherServer && \
    cd .. && rm -Rf ./build && rm -Rf ~/.local/* && \
    rm -rf /var/lib/apt/lists/*

FROM debian:sid-slim AS final
ARG project
ENV env_project=$project
WORKDIR /
COPY --from=builder "/usr/local/bin/${project}TogetherServer" "/${project}TogetherServer"
ENTRYPOINT "/${env_project}TogetherServer"

EXPOSE 10578/udp
