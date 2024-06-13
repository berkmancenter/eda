FROM ruby:3.3.3

RUN apt-get update && apt-get -y install nodejs tzdata git build-essential patch ruby-dev zlib1g-dev liblzma-dev default-jre

RUN mkdir /app
WORKDIR /app

COPY . .
RUN bundle install

CMD (rm -rf tmp/pids/server.pid || true) && (while true; do sleep 1; done;)
