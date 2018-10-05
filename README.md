# Self-signed certificate companion for Nginx-Proxy

**WARNING ! Self-signed certificates should only be used on local projects !**

self-signed-certificate-nginx-proxy-companion is a lightweight companion container for the [nginx-proxy](https://github.com/jwilder/nginx-proxy). It allows the creation of self-signed certificates automatically.

If you need to set Let's Encrypt certificates for production, see : [docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion).

## Features

* Automatic creation self-signed certificates with a **20 years validity period** (!) using original [nginx-proxy](https://github.com/jwilder/nginx-proxy) container.
* Automatic creation of a certificate autority (CA) to trust your self-signed certificates

## Usage

To use it with original [nginx-proxy](https://github.com/jwilder/nginx-proxy) container you must declare 2 volumes :

* `/var/run/docker.sock` (read only) to access docker socket
* `/etc/nginx/certs` (writable) to create self-signed certificates

#### Example:

* First start nginx with the 2 volumes declared:
```bash
$ docker run -d -p 80:80 -p 443:443 \
    --name nginx-proxy \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    -v /path/to/certs:/etc/nginx/certs:ro \
    -v /etc/nginx/vhost.d \
    jwilder/nginx-proxy
```

* Second start this container:
```bash
$ docker run -d \
    --name proxy-companion \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /path/to/certs:/etc/nginx/certs:rw \
    -e "NGINX_PROXY_CONTAINER=nginx-proxy"
    sebastienheyd/self-signed-proxy-companion
```

* Then start any proxied containers with an additional env var `SELF_SIGNED_HOST`
```bash
$ docker run -d \
    --name example-app \
    -e "VIRTUAL_HOST=example.com,www.example.com,mail.example.com" \
    -e "SELF_SIGNED_HOST=example.com" \
    tutum/apache-php
```
**Note** : in this example `SELF_SIGNED_HOST` value `example.com` will cover `*.example.com`, you don't have to add all FQDN. See [wildcard](https://github.com/jwilder/nginx-proxy#wildcard-certificates) documentation.

#### With docker-compose :

First start nginx and companion with the 2 volumes declared:

```yml
version: '2'

services:
    proxy:
        container_name: proxy
        restart: always
        image: jwilder/nginx-proxy
        ports:
            - "80:80"
            - "443:443"
        volumes:
            - /var/run/docker.sock:/tmp/docker.sock:ro
            - ./vhost.d:/etc/nginx/vhost.d
            - ./certs:/etc/nginx/certs
        networks:
            - proxy

    proxy-companion:        
        container_name: proxy-companion
        restart: always
        image: sebastienheyd/self-signed-proxy-companion
        environment:
            NGINX_PROXY_CONTAINER: proxy
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock:ro
            - ./certs:/etc/nginx/certs

networks:
    proxy:
        external: true
```

Then start any proxied containers with an additional env var `SELF_SIGNED_HOST`

```yml
version: '2'

services:
    app:
        container_name: example-app
        image: tutum/apache-php:latest
        environment:
            VIRTUAL_HOST: "example.com,www.example.com,mail.example.com"
            SELF_SIGNED_HOST: "example.com"
        networks:
            - proxy

networks:
    proxy:
        external: true
```

**Note** : in this example `SELF_SIGNED_HOST` value `example.com` will cover `*.example.com`, you don't have to add all FQDN. See [wildcard](https://github.com/jwilder/nginx-proxy#wildcard-certificates) documentation.

## Trust self-signed certificates

This will avoid you to see the alert "your connection is not private".

At the first launch of companion a CA certificate is generated. You will find `ca.crt` in your `certs` folder, this is your CA certificate.

There are several ways to import a CA certificate, here are two of them.

##### Chrome

Go to : `chrome://settings/certificates`

Go to `Trusted Root Certification Authorities` and import `ca.crt`

##### Firefox

Go to `about:config#privacy`

On the bottom of the page, click on `View certificates`, select `Authorities` > `Import` then browse to `ca.crt`.

Check `Trust the CA to identify websites`
