FROM bcit/alpine:3.14-latest
LABEL maintainer="chriswood@gmail.com,jesse@weisner.ca"
LABEL build_id="1634852533"
LABEL nginx_version="1.20.1"

ENV RUNUSER nginx
ENV HOME /var/cache/nginx

RUN printf "%s%s%s\n" \
        "https://nginx.org/packages/alpine/v" \
        "3.14" \
        "/main" \
    | tee -a /etc/apk/repositories \
 && wget -O /etc/apk/keys/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub \
 && apk add --no-cache \
    nginx=1.20.1-r3 \
    nginx-mod-http-geoip2=1.20.1-r3 \
    nginx-mod-stream-geoip2=1.20.1-r3 \
    nginx-mod-http-image-filter=1.20.1-r3 \
    nginx-mod-http-xslt-filter=1.20.1-r3 \
    nginx-mod-http-js=1.20.1-r3 \
    nginx-mod-stream-js=1.20.1-r3

RUN mkdir /application /config \
 && chown nginx:root /var/lib/nginx /var/run /var/log/nginx /run \
 && chmod 1777 /var/lib/nginx/tmp \
 && chmod 775 /var/run /run /var/log/nginx /application \
 && ln -sf /var/lib/nginx/html/index.html /application/index.html \
 #required for 50-copy-nginx-config.sh to copy config files
 && chown nginx:root -R /etc/nginx \
 && find /etc/nginx -type d -exec chmod 775 \{\} \; \
 && find /etc/nginx -type f -exec chmod 664 \{\} \; \
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

COPY 50-copy-config.sh /docker-entrypoint.d/
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

RUN touch /var/lib/nginx/html/ping

USER nginx
WORKDIR /application

EXPOSE 8080
ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
