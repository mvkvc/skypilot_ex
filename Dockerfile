FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

ENV VER_ERL=25.3.1
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
    sudo \
    ninja-build \
    curl \
    libsctp1

# Erlang/OTP
RUN apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk

# Elixir
RUN apt-get -y install unzip

RUN apt-get install -y --no-install-recommends locales
ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
RUN echo $LANG UTF-8 > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=$LANG

# RUN ldd --version
# RUN apt-get install -y libc-bin=2.29 libc6=2.29

RUN apt-get install -y libncurses5

# create a non-root user
ARG USER_ID=1000f
RUN useradd -m --no-log-init --system  --uid ${USER_ID} appuser -g sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER appuser
WORKDIR /home/appuser

ENV PATH="/home/appuser/.local/bin:${PATH}"

# RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.3
# RUN cat ~/.profile
# RUN echo 'export ASDF_DIR="$HOME/.asdf"' >> ~/.profile
# RUN echo '. "$HOME/.asdf/asdf.sh"' >> ~/.profile
# RUN ["/bin/bash", "-c", ". ~/.profile"]

RUN wget https://packages.erlang-solutions.com/erlang/debian/pool/esl-erlang_25.3-1~ubuntu~bionic_amd64.deb
RUN sudo dpkg -i esl-erlang_25.3-1~ubuntu~bionic_amd64.deb
RUN rm esl-erlang_25.3-1~ubuntu~bionic_amd64.deb

RUN wget https://github.com/elixir-lang/elixir/releases/download/v1.14.4/elixir-otp-25.zip
RUN unzip elixir-otp-25.zip -d ./elixir
RUN rm elixir-otp-25.zip
ENV PATH="/home/appuser/elixir/bin:${PATH}"
RUN pwd
RUN ls -la
RUN elixir --version

RUN mix local.hex --force
RUN mix local.rebar --force

# RUN asdf global erlang ${VER_ERL}
# RUN asdf global elixir ${VER_EX}
# RUN asdf install
# RUN asdf reshim

RUN ls -la
RUN ls -la

ADD ./train.exs /home/appuser/train.exs

ENTRYPOINT [ "elixir", "train.exs" ]
