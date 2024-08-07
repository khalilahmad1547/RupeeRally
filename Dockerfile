ARG RUBY_VERSION=3.2.4

FROM ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

ENV PORT=3000 \
    RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES="true" \
    RAILS_MASTER_KEY="6d7eb61bd8aab5749f56deea8bb4f64b" \
    SECRET_KEY_BASE="6d7eb61bd8aab5749f56deea8bb4f64b" \
    NODE_VERSION=18


FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config curl

ENV NVM_DIR=/usr/local/nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

RUN bash -c "source $NVM_DIR/nvm.sh && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION} && \
    npm install -g yarn"

ENV PATH=$NVM_DIR/versions/node/v${NODE_VERSION}/bin:$PATH

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec rails app:update:bin

RUN bundle exec rails assets:precompile 2>&1 | tee /rails/assets_precompile.log

FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

EXPOSE ${PORT}

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

CMD ["./bin/rails", "server", "--port", "${PORT}"]
