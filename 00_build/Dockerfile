FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

ENV VER_ERL=25.3-1
ENV VER_ELIX_ERL=25
ENV VER_ELIX=1.14.4
ENV EXLA_TARGET=cuda
ENV XLA_TARGET=cuda118
# ENV XLA_FLAGS=

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
    ca-certificates \
    git \
    wget \
    curl

# Erlang/OTP, unsure which neededs
RUN apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk libsctp1 libncurses5

# Elixir
RUN apt-get -y install unzip

# Fix latin1 encoding error in Elixir
RUN apt-get install -y --no-install-recommends locales
ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
RUN echo $LANG UTF-8 > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=$LANG

WORKDIR /root

RUN wget https://packages.erlang-solutions.com/erlang/debian/pool/esl-erlang_"${VER_ERL}"~ubuntu~bionic_amd64.deb
RUN dpkg -i esl-erlang_"${VER_ERL}"~ubuntu~bionic_amd64.deb
RUN rm esl-erlang_"${VER_ERL}"~ubuntu~bionic_amd64.deb

RUN wget https://github.com/elixir-lang/elixir/releases/download/v"${VER_ELIX}"/elixir-otp-"${VER_ELIX_ERL}".zip
RUN unzip elixir-otp-"${VER_ELIX_ERL}".zip -d /elixir
RUN rm elixir-otp-"${VER_ELIX_ERL}".zip
ENV PATH="$HOME/elixir/bin:${PATH}"
RUN elixir --version

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix archive.install hex livebook 0.9.2 --force
RUN livebook --version
