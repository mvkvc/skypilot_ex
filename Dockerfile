FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu18.04

ENV VER_ERL=25.2.1
ENV VER_EX=1.14.5-otp-25
ENV EXLA_TARGET=cuda
ENV XLA_TARGET=cuda111
# Set path if not found
# ENV XLA_FLAGS=

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
    ca-certificates \
    git \
    wget \
    sudo \
    ninja-build \
    curl

# Erlang/OTP
RUN apt-get -y install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk

# Elixir
RUN apt-get -y install unzip

# create a non-root user
ARG USER_ID=1000
RUN useradd -m --no-log-init --system  --uid ${USER_ID} appuser -g sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER appuser
WORKDIR /home/appuser

ENV PATH="/home/appuser/.local/bin:${PATH}"

RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.3
RUN echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
RUN echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc

RUN asdf global erlang ${VER_ERL}
RUN asdf global elixir ${VER_EX}
RUN asdf install
RUN asdf reshim

ADD ./train.exs /home/appuser/train.exs

ENTRYPOINT [ "elixir", "train.exs" ]
