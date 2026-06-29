# syntax=docker/dockerfile:1.7

ARG RUBY_VERSION=4.0.5
FROM docker.io/library/ruby:${RUBY_VERSION}-slim

WORKDIR /app

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libyaml-dev \
      libpq-dev \
      pkg-config \
      postgresql-client && \
    rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=development \
    BUNDLE_PATH=/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    PATH=/bundle/bin:${PATH}

# Install gems early to leverage Docker layer caching.
COPY Gemfile Gemfile.lock ./
RUN --mount=type=cache,target=/bundle/cache \
  bundle install

EXPOSE 3000

CMD ["bash", "-lc", "bundle check || bundle install && bin/rails db:prepare && bin/rails server -b 0.0.0.0 -p 3000"]
