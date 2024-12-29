# syntax=docker/dockerfile:1
FROM debian:bookworm-slim AS builder

RUN apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    curl git ca-certificates build-essential \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sSf -OJ https://sh.rustup.rs && sh rustup-init.sh -y
RUN . /root/.cargo/env && cargo install geckodriver

FROM debian:bookworm-slim

LABEL org.opencontainers.image.authors="Mitsuru Shimamura <smbd.jp@gmail.com>"

ENV LANGUAGE=ja_JP.UTF-8
ENV LANG=ja_JP.UTF-8

RUN apt-get -qq update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    tini \
    ca-certificates \
    firefox-esr \
    ruby-mini-magick \
    ruby-nokogiri \
    ruby-zip \
    ruby-websocket \
    graphicsmagick \
    fonts-noto-cjk \
  && gem install -N selenium-webdriver \
  && gem cleanup \
  && gem sources -c \
  && rm -rf /var/lib/gems/*/cache \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN install -d -m 0755 /save

COPY --chmod=0755 --from=builder /root/.cargo/bin/geckodriver /usr/local/bin
COPY --chmod=0755 ss.rb /usr/local/bin

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/ss.rb"]
