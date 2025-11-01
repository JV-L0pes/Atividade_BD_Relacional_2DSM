-- ============================================
-- Biblioteca
-- ============================================

-- Drop tables
DROP TABLE IF EXISTS emprestimo_livro CASCADE;
DROP TABLE IF EXISTS emprestimo CASCADE;
DROP TABLE IF EXISTS livro CASCADE;
DROP TABLE IF EXISTS autor CASCADE;
DROP TABLE IF EXISTS aluno CASCADE;

-- Tabela Autor
CREATE TABLE autor (
    id_autor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

-- Tabela Livro 
CREATE TABLE livro (
    id_livro SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    ano_publicacao INT,
    paginas INT,
    editora VARCHAR(150),
    id_autor INT REFERENCES autor(id_autor)
);

-- Tabela Aluno
CREATE TABLE aluno (
    id_aluno SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    curso VARCHAR(100) NOT NULL
);

-- Tabela Empréstimo
CREATE TABLE emprestimo (
    id_emprestimo SERIAL PRIMARY KEY,
    data_emprestimo DATE NOT NULL,
    id_aluno INT NOT NULL REFERENCES aluno(id_aluno)
);

-- Tabela associativa Empréstimo_Livro (N:N)
CREATE TABLE emprestimo_livro (
    id_emprestimo INT NOT NULL REFERENCES emprestimo(id_emprestimo),
    id_livro INT NOT NULL REFERENCES livro(id_livro),
    PRIMARY KEY (id_emprestimo, id_livro)
);

-- Inserts: Autores
INSERT INTO autor (nome) VALUES
('J. R. R. Tolkien'),
('Machado de Assis'),
('Clarice Lispector');

-- Inserts: Livros 
INSERT INTO livro (titulo, ano_publicacao, paginas, editora, id_autor) VALUES
('O Senhor dos Anéis', 1954, 1178, 'HarperCollins', 1),
('Dom Casmurro', 1899, 256, 'Editora A', 2),
('A Hora da Estrela', 1977, 128, 'Editora B', 3),
('O Hobbit', 1937, 310, 'HarperCollins', 1),
('Contos Escolhidos', 1900, 200, 'Editora A', 2);  -- adicionando um livro extra para Machado

-- Inserts: Alunos
INSERT INTO aluno (nome, curso) VALUES
('Ana Souza', 'Sistemas de Informação'),
('Bruno Silva', 'Engenharia de Software');

-- Inserts: Empréstimos
INSERT INTO emprestimo (data_emprestimo, id_aluno) VALUES
('2025-08-20', 1),
('2025-08-21', 2);

-- Inserts: Empréstimo_Livro
INSERT INTO emprestimo_livro (id_emprestimo, id_livro) VALUES
(1, 1), -- Ana pegou O Senhor dos Anéis
(1, 2), -- Ana pegou Dom Casmurro
(2, 3); -- Bruno pegou A Hora da Estrela


-- =========================
-- CONSULTAS (exercícios)
-- =========================

-- 1) Listar quantos livros cada autor possui.
-- Retorna o nome do autor e a quantidade de livros relacionados (usa LEFT JOIN para incluir autores com 0 livros).
SELECT
    a.nome AS autor,
    COUNT(l.id_livro) AS qtd_livros
FROM autor AS a
LEFT JOIN livro AS l
    ON a.id_autor = l.id_autor
GROUP BY a.nome
ORDER BY qtd_livros DESC;


-- 2) Mostrar a média de páginas dos livros por editora.
-- Retorna editora, média de páginas (formatada) e quantidade de livros na editora.
SELECT
    l.editora,
    AVG(l.paginas)::numeric(10,2) AS media_paginas,
    COUNT(l.id_livro) AS qtd_livros
FROM livro AS l
GROUP BY l.editora
ORDER BY media_paginas DESC;
