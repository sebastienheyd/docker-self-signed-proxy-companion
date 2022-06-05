FROM nginxproxy/docker-gen:0.9.0 AS docker-gen
FROM alpine:latest

RUN apk add --no-cache --virtual .bin-deps \
    bash \
    curl \
    wget \
    jq \
    openssl

WORKDIR /app
ADD . /app

COPY --from=docker-gen /usr/local/bin/docker-gen /usr/local/bin/

ENV DOCKER_HOST unix:///var/run/docker.sock
ENV NGINX_PROXY_CONTAINER proxy
ENV EXPIRATION 3650

ENTRYPOINT [ "/bin/bash", "/app/entrypoint.sh" ]
CMD [ "/bin/bash", "/app/start.sh" ]
