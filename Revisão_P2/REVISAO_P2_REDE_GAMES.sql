-- Criar banco de dados
CREATE DATABASE rede_games;

-- Conectar ao banco (execute no pgAdmin: clique com botão direito no banco e "Query Tool")
-- OU use o comando: \c rede_games (no psql)

-- ==============================================
-- QUESTÃO 2: CRIAÇÃO DAS TABELAS
-- ==============================================
-- Crie as tabelas com os atributos e restrições conforme especificado

-- Tabela de fabricantes de consoles e acessórios
CREATE TABLE fabricante (
    id_fabricante SERIAL PRIMARY KEY,
    nome_fabricante VARCHAR(100) NOT NULL,
    pais VARCHAR(50)
);

-- Tabela de produtos vendidos na rede de lojas
CREATE TABLE produto (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    preco NUMERIC(10,2) NOT NULL CHECK (preco > 0),
    id_fabricante INT,
    FOREIGN KEY (id_fabricante) REFERENCES fabricante(id_fabricante)
);

-- Tabela de lojas da rede
CREATE TABLE loja (
    id_loja SERIAL PRIMARY KEY,
    nome_loja VARCHAR(120) NOT NULL,
    cidade VARCHAR(80) NOT NULL
);

-- Tabela de vendas
CREATE TABLE venda (
    id_venda SERIAL PRIMARY KEY,
    id_produto INT NOT NULL,
    id_loja INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    data_venda DATE NOT NULL,
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto),
    FOREIGN KEY (id_loja) REFERENCES loja(id_loja)
);

-- ==============================================
-- QUESTÃO 3: INSERÇÃO DE FABRICANTES
-- ==============================================
-- Insira ao menos 3 fabricantes, com países diferentes

INSERT INTO fabricante (nome_fabricante, pais) VALUES
('Nintendo', 'Japão'),
('Sony', 'Japão'),
('Microsoft', 'Estados Unidos'),
('Razer', 'Estados Unidos'),
('HyperX', 'Estados Unidos'),
('Logitech', 'Suíça'),
('Capcom', 'Japão');

-- ==============================================
-- QUESTÃO 4: INSERÇÃO DE PRODUTOS
-- ==============================================
-- Cadastre ao menos 5 produtos associados aos fabricantes criados.
-- Inclua pelo menos 1 acessório e 1 jogo.

INSERT INTO produto (nome, preco, id_fabricante) VALUES
('Nintendo Switch OLED', 2499.90, 1),
('Joy-Con Pair', 499.90, 1),
('PlayStation 5', 4399.00, 2),
('DualSense Controller', 399.90, 2),
('Xbox Series X', 4599.90, 3),
('Xbox Wireless Controller', 349.90, 3),
('Razer Kraken Headset', 499.90, 4),
('HyperX Cloud II Headset', 649.90, 5),
('Logitech G Pro Mouse', 399.90, 6),
('Resident Evil 4 Remake', 299.90, 7),
('Street Fighter 6', 349.90, 7);

-- ==============================================
-- QUESTÃO 5: INSERÇÃO DE LOJAS
-- ==============================================
-- Cadastre 3 lojas em cidades diferentes

INSERT INTO loja (nome_loja, cidade) VALUES
('Rede Games SP - Paulista', 'São Paulo'),
('Rede Games RJ - Barra', 'Rio de Janeiro'),
('Rede Games MG - BH Shopping', 'Belo Horizonte'),
('Rede Games PR - Curitiba', 'Curitiba');

-- ==============================================
-- QUESTÃO 6: INSERÇÃO DE VENDAS
-- ==============================================
-- Registre 6 vendas com quantidades variadas.
-- Os dados devem permitir que consultas com agregação e JOIN funcionem.

INSERT INTO venda (id_produto, id_loja, quantidade, data_venda) VALUES
(1, 1, 20, '2025-09-20'),
(2, 1, 35, '2025-09-21'),
(3, 2, 15, '2025-09-22'),
(4, 2, 40, '2025-10-01'),
(5, 3, 10, '2025-10-02'),
(6, 3, 5, '2025-10-02'),
(7, 4, 12, '2025-10-05'),
(8, 4, 18, '2025-10-05'),
(9, 1, 20, '2025-10-06'),
(10, 2, 25, '2025-10-06'),
(11, 3, 30, '2025-10-07');

-- ==============================================
-- QUESTÃO 7: JOIN — RELATÓRIO DE PRODUTOS VENDIDOS
-- ==============================================
-- Situação: O gerente deseja uma lista de produtos vendidos e em qual loja foram vendidos.
-- Exiba: produto, nome da loja, quantidade
-- Impor JOIN correto entre produto e venda + loja.

SELECT 
    p.nome AS produto,
    l.nome_loja,
    v.quantidade
FROM venda v
INNER JOIN produto p ON v.id_produto = p.id_produto
INNER JOIN loja l ON v.id_loja = l.id_loja
ORDER BY l.nome_loja, p.nome;

-- ==============================================
-- QUESTÃO 8: GROUP BY — TOTAL DE PRODUTOS VENDIDOS POR LOJA
-- ==============================================
-- Situação: A diretoria quer o Total somado de produtos vendidos por loja.
-- Exiba: nome da loja, total vendido

SELECT 
    l.nome_loja,
    SUM(v.quantidade) AS total_vendido
FROM venda v
INNER JOIN loja l ON v.id_loja = l.id_loja
GROUP BY l.id_loja, l.nome_loja
ORDER BY total_vendido DESC;

-- ==============================================
-- QUESTÃO 9: HAVING — LOJAS DE ALTO DESEMPENHO
-- ==============================================
-- Mostre somente lojas que venderam acima de 30 unidades somadas.
-- Filtro deve ser feito no HAVING (não no WHERE)

SELECT 
    l.nome_loja,
    SUM(v.quantidade) AS total_vendido
FROM venda v
INNER JOIN loja l ON v.id_loja = l.id_loja
GROUP BY l.id_loja, l.nome_loja
HAVING SUM(v.quantidade) > 30
ORDER BY total_vendido DESC;

-- ==============================================
-- QUESTÃO 10: SUBCONSULTA — FABRICANTES COM PRODUTOS VENDIDOS
-- ==============================================
-- Situação-problema:
-- "Quais fabricantes já tiveram algum produto vendido ao menos uma vez?"
-- Exibir apenas nome_fabricante.
-- Usar IN OU EXISTS em subconsulta.

-- SOLUÇÃO COM IN:
SELECT 
    f.nome_fabricante
FROM fabricante f
WHERE f.id_fabricante IN (
    SELECT DISTINCT p.id_fabricante
    FROM produto p
    INNER JOIN venda v ON p.id_produto = v.id_produto
)
ORDER BY f.nome_fabricante;

-- SOLUÇÃO COM EXISTS (alternativa):
SELECT 
    f.nome_fabricante
FROM fabricante f
WHERE EXISTS (
    SELECT 1
    FROM produto p
    INNER JOIN venda v ON p.id_produto = v.id_produto
    WHERE p.id_fabricante = f.id_fabricante
)
ORDER BY f.nome_fabricante;

