#!/bin/bash

set -a; source "$(dirname "$0")/.env"; set +a
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
