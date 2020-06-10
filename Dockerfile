FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive
ENV RAILS_ENV=production
ENV NODE_ENV=production

RUN set -ex; \
  apt-get update; \
  apt-get install --yes --no-install-recommends \
    build-essential brotli curl git gnupg ruby ruby-dev \
    libxml2-dev libxslt-dev zlib1g-dev libpq-dev libreadline-dev \
    advancecomp jhead jpegoptim libjpeg-turbo-progs imagemagick optipng pngcrush gifsicle pngquant; \
  echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list; \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
  curl -sL https://deb.nodesource.com/setup_12.x | bash -; \
  apt-get install --yes --no-install-recommends \
    nodejs yarn; \
  rm -rf /var/lib/apt/lists/*; \
  gem update --system --no-document; \
  ln -s /usr/bin/bundle2.7 /usr/bin/bundle; \
  curl -fsLo /tmp/caddy.deb https://github.com/caddyserver/caddy/releases/download/v2.0.0/caddy_2.0.0_linux_amd64.deb; \
  dpkg -i /tmp/caddy.deb; \
  rm /tmp/caddy.deb

RUN git clone --depth 1 https://github.com/discourse/discourse.git /app/current

WORKDIR /app
VOLUME /app/shared
RUN set -ex; \
  cd current; \
  bundle config set deployment 'true'; \
  bundle config set without 'test development'; \
  bundle install --jobs `nproc`; \
  yarn install

COPY files/* /app/

CMD /app/puma
