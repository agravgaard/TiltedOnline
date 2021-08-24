FROM --platform=$BUILDPLATFORM debian:bullseye AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG project

WORKDIR /home/


RUN apt update && \
    apt install -y --no-install-recommends wget ca-certificates tar curl unzip llvm clang && \
    # export buildarchspec=`echo $TARGETPLATFORM | sed -nE 's/linux\///p' | sed -nE 's/\/v7/v7l/p'` && \
    # wget `curl -s musl.cc | grep "$buildarchspec" | grep cross` -O muslcc.tgz && \
    # tar xf muslcc.tgz && \
    # mv ${buildarchspec}* crosstools && \
    wget https://xmake.io/shget.text -O getxmake.sh && \
    bash getxmake.sh
    #&& \

COPY ./ ./build

RUN cd build && \
    export buildarch=`echo $TARGETPLATFORM | sed -nE 's/linux\///p' | sed -nE 's/\///p'` && \
    # XMAKE_ROOT=y ~/.local/bin/xrepo install -y --arch=$buildarch muslcc && \
    # XMAKE_ROOT=y ~/.local/bin/xrepo install -y --arch=$buildarch mimalloc glm && \
    XMAKE_ROOT=y ~/.local/bin/xmake config -y --mode=release --toolchain=llvm --arch=${buildarch} ${project}TogetherServer && \
    XMAKE_ROOT=y ~/.local/bin/xmake -y ${project}TogetherServer && \
    INSTALLDIR=/usr/local/ XMAKE_ROOT=y ~/.local/bin/xmake install -y ${project}TogetherServer
   # && \
   # cd .. && rm -Rf ./build && rm -Rf ~/.local/* && \
   # apt remove -y wget ca-certificates unzip gcc && \
   # apt autoremove -y && \
   # rm -rf /var/lib/apt/lists/*

FROM scratch AS final
WORKDIR /
COPY --from=builder /usr/local/bin/${project}TogetherServer /SkyrimTogetherServer
ENTRYPOINT ["/${project}TogetherServer"]

EXPOSE 10578/udp
