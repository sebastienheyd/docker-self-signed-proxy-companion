[![Docker stars](https://img.shields.io/docker/image-size/sebastienheyd/self-signed-proxy-companion.svg?sort=semver)](https://hub.docker.com/repository/docker/sebastienheyd/self-signed-proxy-companion)
[![Docker pulls](https://img.shields.io/docker/pulls/sebastienheyd/self-signed-proxy-companion.svg)](https://hub.docker.com/repository/docker/sebastienheyd/self-signed-proxy-companion)

# Self-signed certificate companion for Nginx-Proxy

**WARNING ! Self-signed certificates should only be used on local projects !**

self-signed-certificate-nginx-proxy-companion is a lightweight companion container for the [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy). It allows the creation of self-signed certificates automatically.

If you need to set Let's Encrypt certificates for production, see : [acme-companion](https://github.com/nginx-proxy/acme-companion).

## Features

* Automatic creation self-signed certificates with a **10 years validity period** (by default) using original [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) container.
* Automatic creation of a certificate autority (CA) to trust your self-signed certificates
* **NEW (nginx-proxy >= 1.8)**: Automatic generation of client certificates for mutual TLS (mTLS) authentication

## Usage

To use it with original [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) container you must declare 2 volumes :

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
    nginxproxy/nginx-proxy
```

* Second start this container:
```bash
$ docker run -d \
    --name proxy-companion \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /path/to/certs:/etc/nginx/certs:rw \
    sebastienheyd/self-signed-proxy-companion
```

* Then start any proxied containers with an additional env var `SELF_SIGNED_HOST`

```bash
$ docker run -d \
    --name example-app \
    -e "VIRTUAL_HOST=example.com.localhost,www.example.com.localhost,mail.example.com.localhost" \
    -e "SELF_SIGNED_HOST=example.com.localhost" \
    tutum/apache-php
```
**Note** : in this example `SELF_SIGNED_HOST` value `example.com.localhost` will cover `*.example.com.localhost`, you don't have to add all FQDN. See [wildcard](https://github.com/nginx-proxy/nginx-proxy#wildcard-certificates) documentation.

#### With docker-compose :

First start nginx and companion with the 2 volumes declared:

```yml
version: '2'

services:
    proxy:
        container_name: proxy
        restart: always
        image: nginxproxy/nginx-proxy
        ports:
            - "80:80"
            - "443:443"
        volumes:
            - /var/run/docker.sock:/tmp/docker.sock:ro
            - ./vhost.d:/etc/nginx/vhost.d
            - ./certs:/etc/nginx/certs:ro
        networks:
            - proxy

    proxy-companion:        
        container_name: proxy-companion
        restart: always
        image: sebastienheyd/self-signed-proxy-companion
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock:ro
            - ./certs:/etc/nginx/certs:rw

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
            VIRTUAL_HOST: "example.com.localhost,www.example.com.localhost,mail.example.com.localhost"
            SELF_SIGNED_HOST: "example.com.localhost"
        networks:
            - proxy

networks:
    proxy:
        external: true
```

**Note** : in this example `SELF_SIGNED_HOST` value `example.com.localhost` will cover `*.example.com.localhost`, you don't have to add all FQDN. See [wildcard](https://github.com/nginx-proxy/nginx-proxy#wildcard-certificates) documentation.

## Environment variables

| Variable | Default value | Description |
| --- | --- | --- |
| NGINX_PROXY_CONTAINER | proxy | nginxproxy/nginx-proxy container name |
| EXPIRATION | 3650 | Certificates validity period (in days) |
| DOCKER_HOST | unix:///var/run/docker.sock | Path to the docker sock in current container |

## Trust self-signed certificates

This will avoid you to see the alert "your connection is not private".

At the first launch of companion a CA certificate is generated. You will find `ca.crt` in your `certs` folder, this is your CA certificate.

There are several ways to import a CA certificate, here are two of them.

##### Chrome

For MacOS:
- open `Keychain Access`
- drag and drop `ca.crt`
- double clik certificate (can be found by typing `nginx` in search box)
- expand `Trust` in first dropdown select `Always Trust`

Other:
- Go to : `chrome://settings/certificates`
- Go to `Authorities` and import `ca.crt`
- Check `Trust the CA to identify websites`

A quicker solution, but less secure, is to allow insecure certificates for `*.localhost` domains : `chrome://flags/#allow-insecure-localhost`

##### Firefox

- Go to `about:config#privacy` or to `about:preferences#privacy` in newer versions
- At the bottom of the page, click on `View certificates`, select `Authorities` > `Import` then browse to `ca.crt`.
- Check `Trust the CA to identify websites`

## Client Certificate Authentication (nginx-proxy >= 1.8)

Starting with nginx-proxy version 1.8, this companion automatically generates client certificates for mutual TLS authentication. The following files are created in your `certs` folder:

- `client.crt` - Client certificate
- `client.key` - Client private key  
- `client.p12` - PKCS#12 format for browser import

### Using Client Certificates

To use client certificate authentication, import the `client.p12` file into your browser's certificate store. The browser will then automatically present this certificate when accessing sites that require it.

### Disabling Client Certificate Verification

For services that should not require client certificates, add the `com.github.nginx-proxy.nginx-proxy.ssl_verify_client=off` label:

```bash
$ docker run -d \
    --name example-app \
    -e "VIRTUAL_HOST=example.com.localhost" \
    -e "SELF_SIGNED_HOST=example.com.localhost" \
    --label "com.github.nginx-proxy.nginx-proxy.ssl_verify_client=off" \
    tutum/apache-php
```

Or with docker-compose:

```yml
services:
    app:
        container_name: example-app
        image: tutum/apache-php:latest
        environment:
            VIRTUAL_HOST: "example.com.localhost"
            SELF_SIGNED_HOST: "example.com.localhost"
        labels:
            - "com.github.nginx-proxy.nginx-proxy.ssl_verify_client=off"
        networks:
            - proxy

networks:
    proxy:
        external: true
```

This ensures that the service remains accessible via standard HTTPS without requiring client certificate installation.
