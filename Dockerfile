# vim:set ft=dockerfile:
FROM alpine:edge

RUN apk add --update darkhttpd; \
rm -rf /var/cache/apk/*;
COPY . /www
RUN chown -R nobody:nogroup /www
USER nobody

WORKDIR /www

EXPOSE 8080
CMD ["darkhttpd", "."]  
