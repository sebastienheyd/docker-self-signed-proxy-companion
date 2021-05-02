FROM alpine:latest

RUN apk add --no-cache \
        bash \
        curl \
        wget \
        jq \
        openssl

RUN DOCKER_GEN_VERSION=$(curl -s https://api.github.com/repos/jwilder/docker-gen/releases/latest | grep 'tag_name' | cut -d\" -f4) \
    && wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
    && tar xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz -C /usr/local/bin \
    && rm docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

WORKDIR /app
ADD . /app

ENV DOCKER_HOST unix:///var/run/docker.sock
ENV NGINX_PROXY_CONTAINER proxy
ENV EXPIRATION 3650

ENTRYPOINT [ "/bin/bash", "/app/entrypoint.sh" ]
CMD [ "/bin/bash", "/app/start.sh" ]
