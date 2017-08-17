# vim:set ft=dockerfile:
FROM alpine:edge

RUN apk add --update \
      ruby ruby-bigdecimal ruby-bundler \
      linux-headers \
      exiv2 ca-certificates libressl \
      libressl-dev build-base ruby-dev; \

gem install json rack unicorn --no-rdoc --no-ri; \
gem cleanup; \
rm -rf /usr/lib/ruby/gems/*/cache/*; \
apk del libressl-dev build-base ruby-dev; \
rm -rf /var/cache/apk/*;
COPY . /magic-numbers
RUN chown -R nobody:nogroup /magic-numbers
USER nobody

ENV RACK_ENV production  
WORKDIR /magic-numbers

EXPOSE 8080
CMD ["unicorn", "-p", "8080"]  
