#!/usr/bin/env bash
docker-gen -interval 10 -only-exposed -watch -notify-output -notify "bash /tmp/cert" cert.tmpl /tmp/cert
