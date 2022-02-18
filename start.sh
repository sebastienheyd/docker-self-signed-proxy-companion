#!/usr/bin/env bash
docker-gen -only-exposed -watch -notify-output -notify "bash /tmp/cert" cert.tmpl /tmp/cert
