#FROM debian:bullseye-slim AS builder
FROM debian:sid-slim AS builder

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    wget git ca-certificates build-essential \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN wget --content-disposition https://sh.rustup.rs && sh rustup-init.sh -y

# require, until 4.1.2 will be released
RUN cd /tmp && wget --content-disposition https://github.com/SeleniumHQ/selenium/commit/195671ce91808096aa73b4209c2b3c5f5b946d25.diff

RUN . /root/.cargo/env && cargo install geckodriver

FROM debian:sid-slim

MAINTAINER Mitsuru Shimamura <smbd.jp@gmail.com>

ENV LANGUAGE ja_JP.UTF-8
ENV LANG ja_JP.UTF-8

COPY --from=builder /tmp/195671ce91808096aa73b4209c2b3c5f5b946d25.diff /tmp

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    firefox \
    ruby-mini-magick \
    graphicsmagick \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    fonts-noto-mono \
    vim less patch \
  && gem install selenium-webdriver \
  && cd /var/lib/gems/*/gems/selenium-webdriver-* && head -88 /tmp/195671ce91808096aa73b4209c2b3c5f5b946d25.diff | patch -p2 \
  && apt-get remove -y patch \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN install -d -m 0755 /save

COPY --chmod=0755 --from=builder /root/.cargo/bin/geckodriver /usr/local/bin
COPY --chmod=0755 ss.rb /usr/local/bin

COPY dot.mozilla /root/.mozilla

ENTRYPOINT ["/usr/local/bin/ss.rb"]
#ENTRYPOINT ["/bin/bash"]
