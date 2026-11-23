#!/bin/bash
# Constroi as imagens dos hosts usadas em topologia.clab.yml
set -e
cd "$(dirname "$0")"
docker build -t lab-mysql:1.0 hosts/host1
docker build -t lab-http:1.0 hosts/host2
# Imagem do VyOS (demorada, so quando necessario):
# docker build -t vyos:2026.03 roteadores/vyos-imagem
