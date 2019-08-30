FROM nginx:1.15-alpine
LABEL maintainer="chriswood@gmail.com"
LABEL nginx_version="1.15"
LABEL build_id="1567199712"

## START addition of DE from bcit/alpine
ENV RUNUSER none
ENV HOME /

# Add docker-entrypoint script base
ADD https://github.com/itsbcit/docker-entrypoint/releases/download/v1.5/docker-entrypoint.tar.gz /docker-entrypoint.tar.gz
RUN tar zxvf docker-entrypoint.tar.gz && rm -f docker-entrypoint.tar.gz \
 && chmod -R 555 /docker-entrypoint.* \
 && chmod 664 /etc/passwd /etc/group /etc/shadow \
 && chown 0:0 /etc/shadow \
 && chmod 775 /etc

# Add Tini
ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini-static-amd64 /tini
RUN chmod +x /tini

## END addition of DE from bcit/alpine

RUN chown nginx:root /var/cache/nginx /var/run /var/log/nginx /run \
 && chmod 770 /var/cache/nginx \
 && chmod 775 /var/run /run /var/log/nginx \
 && sed -i "s/user  nginx;/#user  nginx;/" /etc/nginx/nginx.conf \
 && sed -i "s/listen       80;/listen       8080;/" /etc/nginx/conf.d/default.conf \
 #required for 50-copy-nginx-config.sh to copy config files
 && chmod 775 -R /etc/nginx/

COPY 50-copy-nginx-config.sh /docker-entrypoint.d/

RUN touch /usr/share/nginx/html/ping

USER nginx
WORKDIR /application

EXPOSE 8080
ENTRYPOINT ["/tini", "--", "/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
