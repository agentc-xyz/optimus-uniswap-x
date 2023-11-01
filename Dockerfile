FROM rust:1 as build

ENV SUBSTREAMS_VERSION=v1.1.14

# install wasm32 toolchain
RUN rustup target add wasm32-unknown-unknown

RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/amd64/x86_64/) && \
    wget https://github.com/streamingfast/substreams/releases/download/$SUBSTREAMS_VERSION/substreams_linux_${arch}.tar.gz && \
                tar -xvf substreams_linux_${arch}.tar.gz && \
                mv substreams /usr/local/bin
WORKDIR /app


RUN --mount=type=bind,source=src,target=src \
    --mount=type=bind,source=proto,target=proto \
    --mount=type=bind,source=abi,target=abi \
    --mount=type=bind,source=Cargo.toml,target=Cargo.toml \
    --mount=type=bind,source=Cargo.lock,target=Cargo.lock \
    --mount=type=bind,source=schema.sql,target=schema.sql \
    --mount=type=bind,source=substreams.yaml,target=substreams.yaml \
    --mount=type=bind,source=Makefile,target=Makefile \
    --mount=type=cache,target=/app/target/ \
    --mount=type=cache,target=/usr/local/cargo/registry/ \
    <<EOF
set -e
make pack
mkdir -p /pack/
cp uniswap-x-v0.1.0.spkg /pack/substreams.spkg
EOF

FROM debian:bullseye as application
ARG TARGET

ENV SUBSTREAMS_POSTGRES_VERSION=v3.0.5
ENV SUBSTREAMS_GIT_REPO=https://github.com/streamingfast/substreams-sink-sql/releases/download

RUN apt-get update && \
            apt-get install -y wget \
                               make && \
            rm -rf /var/lib/apt/lists/*

# install substreams-sink-postgres
RUN arch=$(arch | sed s/aarch64/arm64/ | sed s/amd64/x86_64/) && \
    wget $SUBSTREAMS_GIT_REPO/$SUBSTREAMS_POSTGRES_VERSION/substreams-sink-sql_linux_$arch.tar.gz && \
            tar -xvf substreams-sink-sql_linux_$arch.tar.gz && \
            mv substreams-sink-sql /usr/local/bin

WORKDIR /app

ENV SUBSTREAMS_PACKAGE_FILE=substreams.spkg

COPY --from=build /pack/substreams.spkg ./substreams.spkg
COPY ./Makefile ./Makefile

# setup + sink
ENTRYPOINT ["make"]
CMD ["execute"]
