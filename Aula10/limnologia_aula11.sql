-- ============================================
-- limnologia_db
-- ============================================

-- Drop tables
DROP TABLE IF EXISTS serie_temporal CASCADE;
DROP TABLE IF EXISTS campanha CASCADE;
DROP TABLE IF EXISTS reservatorio CASCADE;

-- Tabela Reservatório
CREATE TABLE reservatorio (
    id_reservatorio SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL
);

-- Tabela Campanha
CREATE TABLE campanha (
    id_campanha SERIAL PRIMARY KEY,
    id_reservatorio INT NOT NULL REFERENCES reservatorio(id_reservatorio),
    data_coleta DATE NOT NULL,
    instituicao VARCHAR(200) NOT NULL
);

-- Tabela Série Temporal
CREATE TABLE serie_temporal (
    id_serie SERIAL PRIMARY KEY,
    id_campanha INT NOT NULL REFERENCES campanha(id_campanha),
    parametro VARCHAR(100) NOT NULL,
    valor NUMERIC(12,4) NOT NULL,
    data_hora TIMESTAMP NOT NULL
);

-- Inserts: Reservatórios
INSERT INTO reservatorio (nome) VALUES
('Represa São João'),
('Lago Azul'),
('Barragem das Flores');

-- Inserts: Campanhas (várias campanhas para gerar contagens)
-- Instituições: "Inst A" realizará 4 campanhas (para exemplo do HAVING > 3)
INSERT INTO campanha (id_reservatorio, data_coleta, instituicao) VALUES
(1, '2025-01-10', 'Inst A'),
(1, '2025-02-15', 'Inst A'),
(1, '2025-03-20', 'Inst A'),
(1, '2025-04-25', 'Inst A'),  -- Inst A: 4 campanhas
(2, '2025-05-05', 'Inst B'),
(2, '2025-06-10', 'Inst B'),
(3, '2025-07-12', 'Inst C');

-- Inserts: Séries temporais
INSERT INTO serie_temporal (id_campanha, parametro, valor, data_hora) VALUES
(1, 'pH', 7.12, '2025-01-10 09:00:00'),
(1, 'Oxigênio Dissolvido', 6.25, '2025-01-10 09:05:00'),
(2, 'pH', 7.30, '2025-02-15 10:00:00'),
(2, 'Oxigênio Dissolvido', 5.90, '2025-02-15 10:05:00'),
(3, 'pH', 6.95, '2025-03-20 11:00:00'),
(3, 'Temperatura', 22.5, '2025-03-20 11:05:00'),
(4, 'pH', 7.05, '2025-04-25 12:00:00'),
(5, 'pH', 7.50, '2025-05-05 09:30:00'),
(5, 'Oxigênio Dissolvido', 6.80, '2025-05-05 09:35:00'),
(6, 'Temperatura', 23.1, '2025-06-10 10:20:00'),
(7, 'pH', 7.00, '2025-07-12 08:50:00');


-- =========================
-- CONSULTAS (exercícios)
-- =========================

-- 3) Listar o total de campanhas por reservatório.
-- Retorna o nome do reservatório e quantas campanhas foram realizadas nele.
SELECT
    r.nome AS reservatorio,
    COUNT(c.id_campanha) AS total_campanhas
FROM reservatorio AS r
INNER JOIN campanha AS c
    ON r.id_reservatorio = c.id_reservatorio
GROUP BY r.nome
ORDER BY total_campanhas DESC;


-- 4) Mostrar a média de valores de cada parâmetro em séries temporais.
-- Retorna cada parâmetro e sua média de medida (agrupamento por parâmetro).
SELECT
    st.parametro,
    AVG(st.valor)::numeric(12,4) AS media_valor,
    COUNT(st.id_serie) AS n_medidas
FROM serie_temporal AS st
GROUP BY st.parametro
ORDER BY parametro;


-- 5) Exibir apenas as instituições que realizaram mais de 3 campanhas.
-- Usa HAVING para filtrar grupos com contagem > 3.
SELECT
    c.instituicao,
    COUNT(c.id_campanha) AS total_campanhas
FROM campanha AS c
GROUP BY c.instituicao
HAVING COUNT(c.id_campanha) > 3
ORDER BY total_campanhas DESC;
