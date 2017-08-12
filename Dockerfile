# vim:set ft=dockerfile:
FROM alpine:edge

RUN apk add --update \
      ruby ruby-bigdecimal ruby-bundler \
      linux-headers \
      exiv2 ca-certificates libressl \
      libressl-dev build-base ruby-dev R R-dev; \

gem install json rack unicorn --no-rdoc --no-ri; \
gem cleanup; \
Rscript -e 'install.packages("TSP", repos="https://cran.rstudio.com")'; \
rm -rf /usr/lib/ruby/gems/*/cache/*; \
apk del libressl-dev build-base ruby-dev; \
rm -rf /var/cache/apk/*;
COPY . /app
RUN chown -R nobody:nogroup /app  
USER nobody

ENV RACK_ENV production  
WORKDIR /app

CMD ["unicorn", "-p", "8080"]  
