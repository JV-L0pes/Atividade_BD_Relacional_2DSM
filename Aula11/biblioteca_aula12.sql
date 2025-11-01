-- ====================================================
-- Biblioteca
-- ====================================================

-- Drop das tabelas (ordem segura para FKs)
DROP TABLE IF EXISTS emprestimo_livro CASCADE;
DROP TABLE IF EXISTS emprestimo CASCADE;
DROP TABLE IF EXISTS livro CASCADE;
DROP TABLE IF EXISTS autor CASCADE;
DROP TABLE IF EXISTS aluno CASCADE;

-- Tabela autor
CREATE TABLE autor (
    id_autor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

-- Tabela livro (inclui páginas e editora para os exercícios)
CREATE TABLE livro (
    id_livro SERIAL PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    ano_publicacao INT,
    paginas INT,
    editora VARCHAR(150),
    id_autor INT REFERENCES autor(id_autor)
);

-- Tabela aluno
CREATE TABLE aluno (
    id_aluno SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    curso VARCHAR(100) NOT NULL
);

-- Tabela emprestimo
CREATE TABLE emprestimo (
    id_emprestimo SERIAL PRIMARY KEY,
    data_emprestimo DATE NOT NULL,
    id_aluno INT NOT NULL REFERENCES aluno(id_aluno)
);

-- Tabela associativa emprestimo_livro
CREATE TABLE emprestimo_livro (
    id_emprestimo INT NOT NULL REFERENCES emprestimo(id_emprestimo),
    id_livro INT NOT NULL REFERENCES livro(id_livro),
    PRIMARY KEY (id_emprestimo, id_livro)
);

-- Inserts: autores
INSERT INTO autor (nome) VALUES
('J. R. R. Tolkien'),
('Machado de Assis'),
('Clarice Lispector');

-- Inserts: livros (vários autores e editoras)
INSERT INTO livro (titulo, ano_publicacao, paginas, editora, id_autor) VALUES
('O Senhor dos Anéis', 1954, 1178, 'HarperCollins', 1),
('O Hobbit', 1937, 310, 'HarperCollins', 1),
('Dom Casmurro', 1899, 256, 'Editora A', 2),
('Contos Escolhidos', 1900, 200, 'Editora A', 2),
('A Hora da Estrela', 1977, 128, 'Editora B', 3);

-- Inserts: alunos
INSERT INTO aluno (nome, curso) VALUES
('Ana Souza', 'Sistemas de Informação'),
('Bruno Silva', 'Engenharia de Software');

-- Inserts: emprestimos
INSERT INTO emprestimo (data_emprestimo, id_aluno) VALUES
('2025-08-20', 1),
('2025-08-21', 2);

-- Inserts: emprestimo_livro
INSERT INTO emprestimo_livro (id_emprestimo, id_livro) VALUES
(1, 1),
(1, 3),
(2, 5);


-- ====================================================
-- CONSULTAS
-- ====================================================

-- Consulta 1:
-- Listar quantos livros cada autor publicou por editora.
-- Uso de LEFT JOIN para garantir que autores sem livros apareçam (caso existam).
SELECT
    a.nome AS autor,
    COALESCE(l.editora, 'SEM_EDITORA') AS editora,
    COUNT(l.id_livro) AS qtd_livros
FROM autor AS a
LEFT JOIN livro AS l
    ON a.id_autor = l.id_autor
GROUP BY a.nome, COALESCE(l.editora, 'SEM_EDITORA')
ORDER BY a.nome, qtd_livros DESC;


-- Consulta 2:
-- Listar a média de páginas dos livros por autor.
-- LEFT JOIN para incluir autores sem livros (média será NULL nesses casos).
SELECT
    a.nome AS autor,
    AVG(l.paginas)::numeric(10,2) AS media_paginas,
    COUNT(l.id_livro) AS qtd_livros
FROM autor AS a
LEFT JOIN livro AS l
    ON a.id_autor = l.id_autor
GROUP BY a.nome
ORDER BY media_paginas DESC NULLS LAST;
