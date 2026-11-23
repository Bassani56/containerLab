#!/bin/bash

cd "$(dirname "$0")" || exit 1
set -a; source ./.env; set +a
# Pastas de bind que nao sao versionadas no git
mkdir -p hosts/host1/mysql/dados aplicacoes/banco/init
read -p "start(1) or replace(2)? " option

if [ "$option" = "1" ]; then
    sudo -E containerlab deploy -t ./topologia.clab.yml --reconfigure

elif [ "$option" = "2" ]; then
    sudo -E containerlab destroy -t ./topologia.clab.yml
    sudo -E containerlab deploy -t ./topologia.clab.yml

else
    echo "Opção inválida! Digite 1 ou 2."
    exit 1
fi
