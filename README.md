# Laboratório Containerlab — rede-laboratorio

## Uso rápido
1. `cp .env.example .env` e preencha as senhas.
2. `./build_imagens.sh` — constrói as imagens dos hosts.
3. `./run_topologia.sh` — sobe (ou recria) a topologia.
4. `./configurar_rotas.sh` — cria no Linux Mint as rotas para as LANs via Router B.
5. `./acessar_maquina.sh` — abre o terminal de um host ou roteador.

## Estrutura
```
topologia.clab.yml        definição da topologia
*.sh                      scripts de uso diário
.env / .env.example       senhas (o .env não vai para o git)
fluxograma/               diagramas da topologia
docs/                     anotações e passo a passo
hosts/<host>/             imagem (Dockerfile) e configs de cada host
  host1/                  servidor MariaDB (dados em mysql/dados, ignorado no git)
  host2/                  servidor HTTP nginx
aplicacoes/               código e conteúdo das aplicações
  site/                   arquivos servidos pelo host2 (/var/www/html)
  banco/init/             scripts SQL do banco
roteadores/               arquivos dos roteadores VyOS
  vyos-imagem/            build da imagem vyos:2026.03 (arquivos grandes ignorados)
```

Novo host: crie `hosts/<nome>/` com o Dockerfile e adicione o nó em `topologia.clab.yml`.
Nova aplicação: crie `aplicacoes/<nome>/` e monte-a no host com `binds`.
