#!/bin/bash

echo "================================"
echo "       CRIAR ROTAS DO LABORATORIO"
echo "================================"

ROTEADOR_B="172.20.20.7"

echo "[1/5] Rota para a LAN do Router A"
sudo ip route replace 192.168.10.0/24 via "$ROTEADOR_B"

echo "[2/5] Rota para o enlace Router A - Router B"
sudo ip route replace 10.0.0.0/30 via "$ROTEADOR_B"

echo "[3/5] Rota para o enlace Router B - Router C"
sudo ip route replace 10.0.0.4/30 via "$ROTEADOR_B"

echo "[4/5] Rota para a LAN do Router C"
sudo ip route replace 192.168.20.0/24 via "$ROTEADOR_B"

echo "[5/5] Rota para a rede do ISP"
sudo ip route replace 203.0.113.0/30 via "$ROTEADOR_B"

echo "================================"
echo "       ROTAS CONFIGURADAS!"
echo "================================"
