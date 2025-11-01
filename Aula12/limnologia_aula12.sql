-- ======================================================
-- Subconsultas escalares no SELECT (limnologia_db)

-- ======================================================

DROP TABLE IF EXISTS serie_temporal CASCADE;
DROP TABLE IF EXISTS parametro CASCADE;
DROP TABLE IF EXISTS reservatorio CASCADE;

CREATE TABLE reservatorio (
    id_reservatorio SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL
);

CREATE TABLE parametro (
    id_parametro SERIAL PRIMARY KEY,
    nome_parametro VARCHAR(100) NOT NULL
);

-- NOTE: serie_temporal contém id_reservatorio diretamente para facilitar o exercício
CREATE TABLE serie_temporal (
    id_serie SERIAL PRIMARY KEY,
    id_reservatorio INT NOT NULL REFERENCES reservatorio(id_reservatorio),
    id_parametro INT NOT NULL REFERENCES parametro(id_parametro),
    valor NUMERIC(12,4) NOT NULL,
    data_hora TIMESTAMP NOT NULL
);


-- -------------------------
-- Inserts de exemplo (dados de pH e outros parâmetros)
-- -------------------------

-- Reservatórios (usados no exemplo do enunciado)
INSERT INTO reservatorio (nome) VALUES
('Jaguari'),
('Paraibuna'),
('Cachoeira do França');

-- Parâmetros
INSERT INTO parametro (nome_parametro) VALUES
('pH'),
('Temperatura'),
('Oxigênio Dissolvido');

-- Para facilitar leitura: id_parametro => 1=pH, 2=Temperatura, 3=Oxigênio Dissolvido

-- Séries temporais (somente algumas amostras de pH + outras medidas)
-- Jaguari: pH = 7.1, 7.2, 7.3  -> média 7.20, min 7.10, max 7.30
INSERT INTO serie_temporal (id_reservatorio, id_parametro, valor, data_hora) VALUES
(1, 1, 7.10, '2025-01-10 08:00:00'),
(1, 1, 7.20, '2025-01-10 08:05:00'),
(1, 1, 7.30, '2025-01-10 08:10:00'),
(1, 2, 22.5, '2025-01-10 09:00:00'); -- temperatura (irrelevante para pH)

-- Paraibuna: pH = 6.9 (único registro)
INSERT INTO serie_temporal (id_reservatorio, id_parametro, valor, data_hora) VALUES
(2, 1, 6.90, '2025-02-20 10:00:00'),
(2, 3, 6.2, '2025-02-20 10:05:00'); -- oxigênio (irrelevante para pH)

-- Cachoeira do França: pH = 7.5, 7.6, 7.7 -> média 7.60, min 7.50, max 7.70
INSERT INTO serie_temporal (id_reservatorio, id_parametro, valor, data_hora) VALUES
(3, 1, 7.50, '2025-03-15 11:00:00'),
(3, 1, 7.60, '2025-03-15 11:05:00'),
(3, 1, 7.70, '2025-03-15 11:10:00'),
(3, 2, 21.0, '2025-03-15 12:00:00'); -- temperatura extra


-- ======================================================
-- Passo 1: Conferir os dados existentes
-- ======================================================

-- a) Contagem total de medições de pH
-- Mostra se há registros do parâmetro 'pH' no banco.
SELECT
    COUNT(st.*) AS qtd_medicoes_pH
FROM serie_temporal AS st
INNER JOIN parametro AS p ON st.id_parametro = p.id_parametro
WHERE p.nome_parametro = 'pH';


-- b) Amostras de pH (exibir algumas linhas para inspeção)
SELECT
    r.nome AS reservatorio,
    p.nome_parametro,
    st.valor,
    st.data_hora
FROM serie_temporal AS st
INNER JOIN reservatorio AS r ON st.id_reservatorio = r.id_reservatorio
INNER JOIN parametro AS p ON st.id_parametro = p.id_parametro
WHERE p.nome_parametro = 'pH'
ORDER BY r.nome, st.data_hora
LIMIT 20;


-- ======================================================
-- Passo 2 → 4: Consulta com subconsultas escalares correlacionadas
-- Para cada reservatório (linha externa) executamos 3 subconsultas:
--   - média do pH (media_ph)
--   - mínimo do pH  (min_ph)
--   - máximo do pH  (max_ph)
-- Cada subconsulta referencia a linha externa via "s.id_reservatorio = r.id_reservatorio"
-- (isto é o que torna a subconsulta CORRELACIONADA).
-- ======================================================

SELECT
    r.nome AS reservatorio,

    -- Subconsulta 1: média do pH para o reservatório atual
    (
        SELECT AVG(s.valor)::numeric(10,2)
        FROM serie_temporal AS s
        INNER JOIN parametro AS p ON s.id_parametro = p.id_parametro
        WHERE s.id_reservatorio = r.id_reservatorio
          AND p.nome_parametro = 'pH'
    ) AS media_ph,

    -- Subconsulta 2: pH mínimo para o reservatório atual
    (
        SELECT MIN(s.valor)
        FROM serie_temporal AS s
        INNER JOIN parametro AS p ON s.id_parametro = p.id_parametro
        WHERE s.id_reservatorio = r.id_reservatorio
          AND p.nome_parametro = 'pH'
    ) AS ph_minimo,

    -- Subconsulta 3: pH máximo para o reservatório atual
    (
        SELECT MAX(s.valor)
        FROM serie_temporal AS s
        INNER JOIN parametro AS p ON s.id_parametro = p.id_parametro
        WHERE s.id_reservatorio = r.id_reservatorio
          AND p.nome_parametro = 'pH'
    ) AS ph_maximo

FROM reservatorio AS r
ORDER BY r.nome;


-- ======================================================
-- Notas explicativas:
-- 1) Por que cada subconsulta é "correlacionada"?
--    Porque dentro da subconsulta usamos "s.id_reservatorio = r.id_reservatorio",
--    referindo-nos à linha atual da consulta externa (alias r). Assim a subconsulta
--    depende do valor da linha externa para calcular seu resultado.
--
-- 2) O que aconteceria se removêssemos o filtro "s.id_reservatorio = r.id_reservatorio"?
--    A subconsulta deixaria de ser correlacionada e retornaria um único valor agregado
--    global (por exemplo, a média de pH de TODOS os reservatórios). Isso levaria à mesma
--    média em todas as linhas da consulta externa — o resultado seria incorreto para o objetivo.
--
-- 3) Observação de performance / alternativa:
--    Subconsultas correlacionadas podem ser menos eficientes em grandes volumes porque
--    o SGBD calcula (ou otimiza) a subconsulta para cada linha. Uma alternativa eficiente
--    e idiomática é calcular agregados por reservatório com uma única agregação (GROUP BY)
--    e juntá-la ao resultado dos reservatórios — exemplo abaixo.
-- ======================================================


-- ======================================================
-- Versão alternativa (sem subconsultas correlacionadas) usando GROUP BY + JOIN
-- (Melhor performance em grandes bases; retorna os mesmos resultados)
-- ======================================================
SELECT
    r.nome AS reservatorio,
    agg.media_ph,
    agg.ph_minimo,
    agg.ph_maximo
FROM reservatorio AS r
LEFT JOIN (
    SELECT
        s.id_reservatorio,
        AVG(s.valor)::numeric(10,2) AS media_ph,
        MIN(s.valor) AS ph_minimo,
        MAX(s.valor) AS ph_maximo
    FROM serie_temporal AS s
    INNER JOIN parametro AS p ON s.id_parametro = p.id_parametro
    WHERE p.nome_parametro = 'pH'
    GROUP BY s.id_reservatorio
) AS agg ON agg.id_reservatorio = r.id_reservatorio
ORDER BY r.nome;
