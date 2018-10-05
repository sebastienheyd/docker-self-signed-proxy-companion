FROM alpine:3.8

RUN apk add --no-cache \
        bash \
        curl \
        wget \
        jq \
        openssl

ENV DOCKER_GEN_VERSION 0.7.4
RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
    && tar xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz -C /usr/local/bin \
    && rm docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

WORKDIR /app
ADD . /app

ENV DOCKER_HOST unix:///var/run/docker.sock
ENV NGINX_PROXY_CONTAINER proxy

ENTRYPOINT [ "/bin/bash", "/app/entrypoint.sh" ]
CMD [ "/bin/bash", "/app/start.sh" ]
