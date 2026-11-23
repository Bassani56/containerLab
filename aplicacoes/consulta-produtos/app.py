#!/usr/bin/env python3
"""
Aplicacao de teste para o laboratorio de DoS.

Escuta em 127.0.0.1:8000 (atras do nginx, que fica na porta 80).
A cada requisicao em /produtos, abre uma conexao nova com o MariaDB
do host1 e faz uma consulta. Isso e de proposito: serve para que uma
sobrecarga no banco (muitas conexoes/queries simultaneas) se reflita
na aplicacao, em vez de escondida por um pool de conexoes.

Rotas:
  GET /produtos                       -> 20 produtos aleatorios
  GET /produtos?categoria=livros      -> 20 produtos da categoria
  GET /produtos?busca=Produto 123     -> busca por nome (LIKE, sem indice)
"""
import json
import os
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs

import pymysql

DB_HOST = os.environ.get("DB_HOST", "192.168.10.10")
DB_USER = os.environ.get("DB_USER", "appuser")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "")
DB_NAME = os.environ.get("DB_NAME", "loja")


def consultar(categoria=None, busca=None):
    inicio = time.monotonic()
    conexao = pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        connect_timeout=3,
        read_timeout=5,
    )
    try:
        with conexao.cursor(pymysql.cursors.DictCursor) as cursor:
            if busca:
                # LIKE sem indice: consulta pesada de proposito, boa para notar o DoS
                cursor.execute(
                    "SELECT id, nome, categoria, preco FROM produtos "
                    "WHERE nome LIKE %s LIMIT 20",
                    (f"%{busca}%",),
                )
            elif categoria:
                cursor.execute(
                    "SELECT id, nome, categoria, preco FROM produtos "
                    "WHERE categoria = %s LIMIT 20",
                    (categoria,),
                )
            else:
                cursor.execute(
                    "SELECT id, nome, categoria, preco FROM produtos LIMIT 20"
                )
            linhas = cursor.fetchall()
    finally:
        conexao.close()
    duracao_ms = round((time.monotonic() - inicio) * 1000, 2)
    return linhas, duracao_ms


class Handler(BaseHTTPRequestHandler):
    def log_message(self, formato, *args):
        pass  # silencia o log padrao; o nginx ja registra acesso

    def do_GET(self):
        caminho = urlparse(self.path)
        if caminho.path != "/produtos":
            self._responder(404, {"erro": "rota nao encontrada"})
            return

        parametros = parse_qs(caminho.query)
        categoria = parametros.get("categoria", [None])[0]
        busca = parametros.get("busca", [None])[0]

        try:
            linhas, duracao_ms = consultar(categoria=categoria, busca=busca)
            self._responder(200, {
                "status": "ok",
                "duracao_ms": duracao_ms,
                "total": len(linhas),
                "produtos": linhas,
            })
        except Exception as erro:
            self._responder(503, {
                "status": "erro",
                "mensagem": str(erro),
            })

    def _responder(self, codigo, corpo):
        dados = json.dumps(corpo, default=str).encode("utf-8")
        self.send_response(codigo)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(dados)))
        self.end_headers()
        self.wfile.write(dados)


if __name__ == "__main__":
    endereco = ("127.0.0.1", 8000)
    servidor = ThreadingHTTPServer(endereco, Handler)
    print(f"Aplicacao escutando em {endereco[0]}:{endereco[1]}")
    servidor.serve_forever()
