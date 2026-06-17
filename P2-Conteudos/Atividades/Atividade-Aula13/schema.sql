-- =====================================================
-- BDR - Atividade Aula 13
-- Tema: Views
-- Banco: biblioteca
-- =====================================================

-- EXERCÍCIO 1 – VIEW: título e número de páginas
CREATE OR REPLACE VIEW vw_livros_paginas AS
SELECT
    titulo,
    paginas AS numero_de_paginas
FROM livro;

-- Teste
SELECT * FROM vw_livros_paginas;

-- =====================================================
-- EXERCÍCIO 2 – VIEW: autores com mais de 1 livro
CREATE OR REPLACE VIEW vw_autores_varios_livros AS
SELECT
    a.nome AS autor,
    COUNT(l.id_livro) AS total_livros
FROM autor a
JOIN livro l ON a.id_autor = l.id_autor
GROUP BY a.id_autor, a.nome
HAVING COUNT(l.id_livro) > 1;

-- Teste
SELECT * FROM vw_autores_varios_livros;

-- =====================================================
-- EXERCÍCIO 3 – VIEW: livros acima da média de páginas
CREATE OR REPLACE VIEW vw_livros_acima_media AS
SELECT
    l.titulo,
    l.paginas,
    ROUND((SELECT AVG(paginas) FROM livro), 2) AS media_paginas
FROM livro l
WHERE l.paginas > (SELECT AVG(paginas) FROM livro);

-- Teste
SELECT * FROM vw_livros_acima_media;

-- =====================================================
-- EXERCÍCIO 4 – VIEW: autor, título e ano de publicação
CREATE OR REPLACE VIEW vw_livros_autor_ano AS
SELECT
    a.nome AS autor,
    l.titulo,
    l.ano_publicacao
FROM autor a
JOIN livro l ON a.id_autor = l.id_autor
ORDER BY a.nome, l.ano_publicacao;

-- Teste
SELECT * FROM vw_livros_autor_ano;

-- =====================================================
-- EXERCÍCIO 5 – VIEW: autor, total de livros, maior nº de páginas
CREATE OR REPLACE VIEW vw_estatisticas_autor AS
SELECT
    a.nome AS autor,
    COUNT(l.id_livro) AS total_livros,
    MAX(l.paginas) AS maior_numero_paginas
FROM autor a
LEFT JOIN livro l ON a.id_autor = l.id_autor
GROUP BY a.id_autor, a.nome
ORDER BY total_livros DESC;

-- Teste
SELECT * FROM vw_estatisticas_autor;
