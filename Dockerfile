FROM bitnami/minideb:jessie

RUN install_packages wget apt-transport-https ca-certificates curl gnupg2 software-properties-common lsb-release

RUN mkdir /app
WORKDIR /app

# Install Docker-gen
ENV DOCKER_GEN_VERSION 0.7.4
RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz
RUN tar xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz -C /usr/local/bin
RUN rm docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

# Install Docker CE
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update && install_packages docker-ce

ADD . /app

ENV DOCKER_HOST unix:///var/run/docker.sock
ENV NGINX_PROXY_CONTAINER proxy

ENTRYPOINT [ "/bin/bash", "/app/entrypoint.sh" ]
CMD [ "/bin/bash", "/app/start.sh" ]
