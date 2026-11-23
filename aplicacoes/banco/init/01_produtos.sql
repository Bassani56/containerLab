-- Schema simples para o laboratorio de teste de carga/DoS.
-- Executado uma unica vez, na primeira inicializacao do host1
-- (ver exec em topologia.clab.yml).

CREATE DATABASE IF NOT EXISTS loja;
USE loja;

CREATE TABLE IF NOT EXISTS produtos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2) NOT NULL
);

-- Usuario usado pela aplicacao do host2 para consultar o banco.
-- A senha real vem da variavel ${APPUSER_PASSWORD}, substituida
-- pelo containerlab antes de executar este script.
CREATE USER IF NOT EXISTS 'appuser'@'192.168.20.%' IDENTIFIED BY '${APPUSER_PASSWORD}';
GRANT SELECT ON loja.* TO 'appuser'@'192.168.20.%';
FLUSH PRIVILEGES;

-- Popula 100 mil linhas usando uma tabela auxiliar numerica,
-- para nao depender de procedures ou loops.
DROP TEMPORARY TABLE IF EXISTS seq;
CREATE TEMPORARY TABLE seq (n INT PRIMARY KEY);

-- Gera 100.000 numeros (0..99999) cruzando 5 conjuntos de 10 valores (10^5 = 100.000).
INSERT INTO seq (n)
SELECT a.n + b.n * 10 + c.n * 100 + d.n * 1000 + e.n * 10000
FROM
    (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
    (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b,
    (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) c,
    (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) d,
    (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) e;

INSERT INTO produtos (nome, categoria, preco)
SELECT
    CONCAT('Produto ', n),
    ELT(1 + (n MOD 5), 'eletronicos', 'alimentos', 'vestuario', 'livros', 'brinquedos'),
    ROUND(5 + (n MOD 1000) * 1.37, 2)
FROM seq;

DROP TEMPORARY TABLE seq;
