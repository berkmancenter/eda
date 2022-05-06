FROM ruby:3.1.1

RUN apt-get update && apt-get -y install nodejs tzdata git build-essential patch ruby-dev zlib1g-dev liblzma-dev default-jre
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
        && apt-get install -y nodejs

RUN mkdir /app
WORKDIR /app

COPY . .
RUN bundle install

CMD (rm -rf tmp/pids/server.pid || true) && (while true; do sleep 1; done;)
