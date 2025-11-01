-- ============================================================
-- Exercício: Subconsultas em WHERE (limnologia_db)
-- Objetivo: mostrar o uso de subconsultas com IN e EXISTS para
-- filtrar reservatórios que possuem medições do parâmetro
-- "Oxigênio Dissolvido".
-- ============================================================

-- DROP / CREATE (idempotente)
DROP TABLE IF EXISTS serie_temporal CASCADE;
DROP TABLE IF EXISTS parametro CASCADE;
DROP TABLE IF EXISTS reservatorio CASCADE;

CREATE TABLE reservatorio (
    id_reservatorio SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL
);

CREATE TABLE parametro (
    id_parametro SERIAL PRIMARY KEY,
    nome_parametro VARCHAR(150) NOT NULL
);

-- serie_temporal contém id_reservatorio para este exercício (modo simplificado)
CREATE TABLE serie_temporal (
    id_serie SERIAL PRIMARY KEY,
    id_reservatorio INT NOT NULL REFERENCES reservatorio(id_reservatorio),
    id_parametro INT NOT NULL REFERENCES parametro(id_parametro),
    valor NUMERIC(12,4) NOT NULL,
    data_hora TIMESTAMP NOT NULL
);

-- -------------------------
-- Inserts de exemplo
-- -------------------------
INSERT INTO reservatorio (nome) VALUES
('Jaguari'),
('Paraibuna'),
('Cachoeira do França'),
('Santa Branca');

INSERT INTO parametro (nome_parametro) VALUES
('pH'),
('Oxigênio Dissolvido'),
('Temperatura');

-- Inserir medições: usamos subqueries para referenciar ids por nome (mais robusto)
-- Jaguari (tem Oxigênio Dissolvido)
INSERT INTO serie_temporal (id_reservatorio, id_parametro, valor, data_hora)
VALUES
(
  (SELECT id_reservatorio FROM reservatorio WHERE nome = 'Jaguari'),
  (SELECT id_parametro FROM parametro WHERE nome_parametro = 'Oxigênio Dissolvido'),
  6.80,
  '2025-01-10 09:00:00'
),
(
  (SELECT id_reservatorio FROM reservatorio WHERE nome = 'Jaguari'),
  (SELECT id_parametro FROM parametro WHERE nome_parametro = 'pH'),
  7.20,
  '2025-01-10 09:05:00'
);

-- Paraibuna (sem Oxigênio Dissolvido neste exemplo)
INSERT INTO serie_temporal (id_reservatorio, id_parametro, valor, data_hora)
VALUES
(
  (SELECT id_reservatorio FROM reservatorio WHERE nome = 'Paraibuna'),
  (SELECT id_parametro FROM parametro WHERE nome_parametro = 'pH'),
  6.90,
  '2025-02-20 10:00:00'
);

-- Cachoeira do França (sem Oxigênio Dissolvido neste exemplo)
INSERT INTO serie_temporal (id_reservatorio, id_parametro, valor, data_hora)
VALUES
(
  (SELECT id_reservatorio FROM reservatorio WHERE nome = 'Cachoeira do França'),
  (SELECT id_parametro FROM parametro WHERE nome_parametro = 'pH'),
  7.60,
  '2025-03-15 11:00:00'
);

-- Santa Branca (tem Oxigênio Dissolvido)
INSERT INTO serie_temporal (id_reservatorio, id_parametro, valor, data_hora)
VALUES
(
  (SELECT id_reservatorio FROM reservatorio WHERE nome = 'Santa Branca'),
  (SELECT id_parametro FROM parametro WHERE nome_parametro = 'Oxigênio Dissolvido'),
  7.00,
  '2025-04-01 08:00:00'
);

-- ============================================================
-- PASSO 1 — Conferir os parâmetros disponíveis
-- (ver quais parâmetros existem e identificar o id/nome do parâmetro "Oxigênio Dissolvido")
-- ============================================================
SELECT * FROM parametro;


-- ============================================================
-- PASSO 2 — Rodar a subconsulta isolada (retorna lista de IDs de reservatórios)
-- Pergunta: "Que tipo de informação ela nos dá?"
-- Resposta (comentário): ela retorna os id_reservatorio que possuem pelo menos
-- uma medição do parâmetro 'Oxigênio Dissolvido' — isto é uma lista de chaves
-- primárias dos reservatórios que participaram de medições desse parâmetro.
-- ============================================================
-- Subconsulta isolada (lista de reservatórios que possuem medidas de O2 dissolvido)
SELECT DISTINCT s.id_reservatorio
FROM serie_temporal AS s
INNER JOIN parametro AS p ON s.id_parametro = p.id_parametro
WHERE p.nome_parametro = 'Oxigênio Dissolvido'
ORDER BY s.id_reservatorio;


-- ============================================================
-- PASSO 3 — Consulta completa usando IN
-- Explicação: a tabela externa (reservatorio) é filtrada por uma lista de ids
-- retornada pela subconsulta. A subconsulta não é correlacionada: roda uma vez.
-- ============================================================
SELECT
    r.nome AS reservatorio
FROM reservatorio AS r
WHERE r.id_reservatorio IN (
    SELECT DISTINCT s.id_reservatorio
    FROM serie_temporal AS s
    INNER JOIN parametro AS p ON s.id_parametro = p.id_parametro
    WHERE p.nome_parametro = 'Oxigênio Dissolvido'
)
ORDER BY r.nome;


-- ============================================================
-- PASSO 4 — Reescrever usando EXISTS (subconsulta correlacionada)
-- Explicação: o EXISTS é correlacionado — para cada linha de r, o planner
-- verifica se existe ao menos uma linha em serie_temporal que satisfaça a condição.
-- O resultado lógico final é o mesmo da versão com IN.
-- ============================================================
SELECT
    r.nome AS reservatorio
FROM reservatorio AS r
WHERE EXISTS (
    SELECT 1
    FROM serie_temporal AS s
    INNER JOIN parametro AS p ON s.id_parametro = p.id_parametro
    WHERE s.id_reservatorio = r.id_reservatorio
      AND p.nome_parametro = 'Oxigênio Dissolvido'
)
ORDER BY r.nome;


-- ============================================================
-- PASSO 5 — Comparar desempenho (opcional/para curiosos)
-- Use EXPLAIN ANALYZE antes das consultas para ver planos e tempos.
-- Em bases pequenas não haverá diferença significativa; em grandes volumes,
-- EXISTS costuma ser mais eficiente quando a subconsulta pode parar ao achar
-- a primeira linha correspondente.
-- ============================================================

-- EXPLAIN ANALYZE para versão IN
EXPLAIN ANALYZE
SELECT r.nome
FROM reservatorio AS r
WHERE r.id_reservatorio IN (
    SELECT DISTINCT s.id_reservatorio
    FROM serie_temporal AS s
    INNER JOIN parametro AS p ON s.id_parametro = p.id_parametro
    WHERE p.nome_parametro = 'Oxigênio Dissolvido'
);

-- EXPLAIN ANALYZE para versão EXISTS
EXPLAIN ANALYZE
SELECT r.nome
FROM reservatorio AS r
WHERE EXISTS (
    SELECT 1
    FROM serie_temporal AS s
    INNER JOIN parametro AS p ON s.id_parametro = p.id_parametro
    WHERE s.id_reservatorio = r.id_reservatorio
      AND p.nome_parametro = 'Oxigênio Dissolvido'
);


-- ============================================================
-- Resultado esperado (com os dados de exemplo acima):
-- Jaguari
-- Santa Branca
-- ============================================================
