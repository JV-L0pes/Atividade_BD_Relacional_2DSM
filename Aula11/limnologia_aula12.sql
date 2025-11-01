-- ====================================================
-- Limnologia_db
-- ====================================================


-- Drop das tabelas (ordem segura para FKs)
DROP TABLE IF EXISTS serie_temporal CASCADE;
DROP TABLE IF EXISTS campanha CASCADE;
DROP TABLE IF EXISTS parametro CASCADE;
DROP TABLE IF EXISTS instituicao CASCADE;
DROP TABLE IF EXISTS reservatorio CASCADE;

-- Tabela reservatorio
CREATE TABLE reservatorio (
    id_reservatorio SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL
);

-- Tabela instituicao
CREATE TABLE instituicao (
    id_instituicao SERIAL PRIMARY KEY,
    nome_instituicao VARCHAR(200) NOT NULL
);

-- Tabela campanha (liga reservatorio + instituicao)
CREATE TABLE campanha (
    id_campanha SERIAL PRIMARY KEY,
    id_reservatorio INT NOT NULL REFERENCES reservatorio(id_reservatorio),
    id_instituicao INT NOT NULL REFERENCES instituicao(id_instituicao),
    data_coleta DATE NOT NULL
);

-- Tabela parametro (lista de parâmetros medidos)
CREATE TABLE parametro (
    id_parametro SERIAL PRIMARY KEY,
    nome_parametro VARCHAR(150) NOT NULL
);

-- Tabela serie_temporal (medidas associadas à campanha e ao parâmetro)
CREATE TABLE serie_temporal (
    id_serie SERIAL PRIMARY KEY,
    id_campanha INT NOT NULL REFERENCES campanha(id_campanha),
    id_parametro INT NOT NULL REFERENCES parametro(id_parametro),
    valor NUMERIC(12,4) NOT NULL,
    data_hora TIMESTAMP NOT NULL
);

-- Inserts: reservatórios
INSERT INTO reservatorio (nome) VALUES
('Represa São João'),
('Lago Azul'),
('Barragem das Flores');

-- Inserts: instituições
INSERT INTO instituicao (nome_instituicao) VALUES
('Inst A'),
('Inst B'),
('Inst C');

-- Inserts: parâmetros
INSERT INTO parametro (nome_parametro) VALUES
('pH'),
('Oxigênio Dissolvido'),
('Temperatura');

-- Inserts: campanhas
-- Organizando campanhas de forma que algumas instituições tenham campanhas em múltiplos reservatórios
INSERT INTO campanha (id_reservatorio, id_instituicao, data_coleta) VALUES
-- Inst A faz campanhas em Represa São João e Lago Azul (2 reservatórios)
(1, 1, '2025-01-10'),
(1, 1, '2025-02-15'),
(2, 1, '2025-03-20'),
(2, 1, '2025-04-25'),
-- Inst B faz campanhas apenas em Lago Azul
(2, 2, '2025-05-05'),
(2, 2, '2025-06-10'),
-- Inst C faz campanhas em Barragem das Flores
(3, 3, '2025-07-12'),
(1, 1, '2025-08-15'); -- Inst A mais uma campanha em Represa São João

-- Inserts: séries temporais (usando id_parametro referenciando a tabela parametro)
-- Para facilitar leitura: id_parametro: 1=pH, 2=Oxigênio Dissolvido, 3=Temperatura
INSERT INTO serie_temporal (id_campanha, id_parametro, valor, data_hora) VALUES
(1, 1, 7.12, '2025-01-10 09:00:00'),
(1, 2, 6.25, '2025-01-10 09:05:00'),
(2, 1, 7.30, '2025-02-15 10:00:00'),
(2, 2, 5.90, '2025-02-15 10:05:00'),
(3, 1, 6.95, '2025-03-20 11:00:00'),
(3, 3, 22.50, '2025-03-20 11:05:00'),
(4, 1, 7.05, '2025-04-25 12:00:00'),
(5, 1, 7.50, '2025-05-05 09:30:00'),
(5, 2, 6.80, '2025-05-05 09:35:00'),
(6, 3, 23.10, '2025-06-10 10:20:00'),
(7, 1, 7.00, '2025-07-12 08:50:00'),
(8, 2, 6.50, '2025-08-15 09:00:00'); -- campanha 8 (id_campanha 8) medida para Inst A

-- ====================================================
-- CONSULTAS — Limnologia (exercícios)
-- ====================================================

-- Consulta 3:
-- Mostrar o total de campanhas por reservatório e instituição.
-- Agrupa por reservatório e instituição para obter a contagem específica (uso de INNER JOIN).
SELECT
    r.nome AS reservatorio,
    i.nome_instituicao AS instituicao,
    COUNT(c.id_campanha) AS total_campanhas
FROM campanha AS c
INNER JOIN reservatorio AS r
    ON c.id_reservatorio = r.id_reservatorio
INNER JOIN instituicao AS i
    ON c.id_instituicao = i.id_instituicao
GROUP BY r.nome, i.nome_instituicao
ORDER BY r.nome, total_campanhas DESC;


-- Consulta 4:
-- Mostrar a média de valores de parâmetros por reservatório.
-- Junta series -> campanha -> reservatorio -> parametro e agrupa por reservatório e parâmetro.
SELECT
    r.nome AS reservatorio,
    p.nome_parametro,
    AVG(st.valor)::numeric(12,4) AS media_valor,
    COUNT(st.id_serie) AS n_medidas
FROM serie_temporal AS st
INNER JOIN campanha AS c
    ON st.id_campanha = c.id_campanha
INNER JOIN reservatorio AS r
    ON c.id_reservatorio = r.id_reservatorio
INNER JOIN parametro AS p
    ON st.id_parametro = p.id_parametro
GROUP BY r.nome, p.nome_parametro
ORDER BY r.nome, p.nome_parametro;


-- Consulta 5:
-- Listar as instituições que coletaram em mais de um reservatório.
-- Agrupa por instituição e conta DISTINCT id_reservatorio; filtra com HAVING > 1.
SELECT
    i.nome_instituicao AS instituicao,
    COUNT(DISTINCT c.id_reservatorio) AS total_reservatorios
FROM instituicao AS i
INNER JOIN campanha AS c
    ON i.id_instituicao = c.id_instituicao
GROUP BY i.nome_instituicao
HAVING COUNT(DISTINCT c.id_reservatorio) > 1
ORDER BY total_reservatorios DESC;
