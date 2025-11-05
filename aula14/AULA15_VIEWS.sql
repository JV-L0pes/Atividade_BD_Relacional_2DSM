-- Conectar ao banco limnologia_db
\c limnologia_db;

-- ====================================================
-- 1. Criar view vw_media_temperatura_reservatorio
-- ====================================================
CREATE OR REPLACE VIEW vw_media_temperatura_reservatorio AS
SELECT 
    r.nome AS nome_reservatorio,
    AVG(st.valor)::NUMERIC(12,4) AS media_temperatura,
    COUNT(st.id_serie) AS quantidade_medicoes
FROM reservatorio r
INNER JOIN serie_temporal st ON r.id_reservatorio = st.id_reservatorio
INNER JOIN parametro p ON st.id_parametro = p.id_parametro
WHERE p.nome_parametro = 'Temperatura'
GROUP BY r.id_reservatorio, r.nome
ORDER BY r.nome;

-- ====================================================
-- 2. Criar view vw_eventos_reservatorio
-- Listando: nome_reservatorio, nome_parametro, valor, data_hora
-- ====================================================
CREATE OR REPLACE VIEW vw_eventos_reservatorio AS
SELECT 
    r.nome AS nome_reservatorio,
    p.nome_parametro,
    st.valor,
    st.data_hora
FROM reservatorio r
INNER JOIN serie_temporal st ON r.id_reservatorio = st.id_reservatorio
INNER JOIN parametro p ON st.id_parametro = p.id_parametro
ORDER BY r.nome, st.data_hora DESC;

-- ====================================================
-- 3. Criar view que mostre apenas reservatórios 
-- com média de turbidez acima de 5
-- ====================================================
CREATE OR REPLACE VIEW vw_reservatorios_turbidez_alta AS
SELECT 
    r.nome AS nome_reservatorio,
    AVG(st.valor)::NUMERIC(12,4) AS media_turbidez,
    COUNT(st.id_serie) AS quantidade_medicoes
FROM reservatorio r
INNER JOIN serie_temporal st ON r.id_reservatorio = st.id_reservatorio
INNER JOIN parametro p ON st.id_parametro = p.id_parametro
WHERE p.nome_parametro = 'Turbidez'
GROUP BY r.id_reservatorio, r.nome
HAVING AVG(st.valor) > 5
ORDER BY media_turbidez DESC;

-- ====================================================
-- 4. Consultar as views criadas
-- ====================================================

-- Consulta 1: Visualizar média de temperatura por reservatório
SELECT * FROM vw_media_temperatura_reservatorio;

-- Consulta 2: Visualizar eventos dos reservatórios
SELECT * FROM vw_eventos_reservatorio;

-- Consulta 3: Visualizar reservatórios com turbidez acima de 5
SELECT * FROM vw_reservatorios_turbidez_alta;

-- ====================================================
-- 5. Remover uma view (DROP VIEW nome)
-- ====================================================
DROP VIEW IF EXISTS vw_reservatorios_turbidez_alta;

-- Verificar se a view foi removida (esta consulta deve gerar erro)
-- SELECT * FROM vw_reservatorios_turbidez_alta;

