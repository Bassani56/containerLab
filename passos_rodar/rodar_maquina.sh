#!/bin/bash

echo "================================"
echo "       REDE LABORATORIO"
echo "================================"
echo "1 - Host"
echo "2 - Roteador"
echo "================================"

read -p "Escolha o tipo de equipamento: " tipo

case "$tipo" in
    1)
        read -p "Digite o host (host1 ou host2): " nome
        ;;
    2)
        read -p "Digite o roteador (A, B, C ou ISP): " nome
        nome=$(echo "$nome" | tr '[:lower:]' '[:upper:]')
        ;;
    *)
        echo "Opcao invalida!"
        exit 1
        ;;
esac

# Monta o nome do container
if [[ "$tipo" == "1" ]]; then
    container="clab-rede-laboratorio-$nome"
else
    container="clab-rede-laboratorio-$nome"
fi

# Verifica se o container existe e está ativo
if ! sudo docker inspect "$container" >/dev/null 2>&1; then
    echo "Container nao encontrado: $container"
    exit 1
fi

if [[ "$(sudo docker inspect -f '{{.State.Running}}' "$container")" != "true" ]]; then
    echo "O container $container nao esta em execucao!"
    exit 1
fi

# Abre o terminal
if [[ "$tipo" == "1" ]]; then
    sudo docker exec -it "$container" sh
else
    sudo docker exec -it "$container" vbash
fi
