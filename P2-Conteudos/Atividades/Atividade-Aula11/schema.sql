-- =====================================================
-- BDR - Atividade Aula 11
-- Tema: GROUP BY com JOINs e Relatórios Avançados
-- Banco: biblioteca
-- =====================================================

-- EXERCÍCIO 1
-- Versão A: Subquery scalar no SELECT
SELECT
    a.nome AS autor,
    (SELECT COUNT(*) FROM livro l WHERE l.id_autor = a.id_autor) AS total_livros,
    (SELECT ROUND(AVG(l.paginas), 2) FROM livro l WHERE l.id_autor = a.id_autor) AS media_paginas
FROM autor a
ORDER BY total_livros DESC;

-- Versão B: CTE (mais legível - evita repetir subqueries)
WITH stats_autor AS (
    SELECT
        l.id_autor,
        COUNT(*) AS total_livros,
        ROUND(AVG(l.paginas), 2) AS media_paginas
    FROM livro l
    GROUP BY l.id_autor
)
SELECT
    a.nome AS autor,
    COALESCE(s.total_livros, 0) AS total_livros,
    COALESCE(s.media_paginas, 0) AS media_paginas
FROM autor a
LEFT JOIN stats_autor s ON a.id_autor = s.id_autor
ORDER BY total_livros DESC;

-- EXERCÍCIO 2
-- Autores cuja soma de páginas ultrapassa a média geral
WITH paginas_por_autor AS (
    SELECT
        l.id_autor,
        SUM(l.paginas) AS soma_paginas
    FROM livro l
    GROUP BY l.id_autor
)
SELECT
    a.nome AS autor,
    p.soma_paginas,
    ROUND((SELECT AVG(soma_paginas) FROM paginas_por_autor), 2) AS media_geral
FROM autor a
JOIN paginas_por_autor p ON a.id_autor = p.id_autor
WHERE p.soma_paginas > (SELECT AVG(soma_paginas) FROM paginas_por_autor)
ORDER BY p.soma_paginas DESC;

-- EXERCÍCIO 3
-- Versão A: Subconsulta correlacionada
SELECT
    a.nome AS autor,
    (SELECT COUNT(*) FROM livro l WHERE l.id_autor = a.id_autor) AS total_livros
FROM autor a
WHERE (SELECT COUNT(*) FROM livro l WHERE l.id_autor = a.id_autor) > 0
ORDER BY total_livros DESC;

-- Versão B: CTE pré-agrupada
WITH livros_por_autor AS (
    SELECT id_autor, COUNT(*) AS total_livros
    FROM livro
    GROUP BY id_autor
    HAVING COUNT(*) > 0
)
SELECT
    a.nome AS autor,
    l.total_livros
FROM autor a
JOIN livros_por_autor l ON a.id_autor = l.id_autor
ORDER BY l.total_livros DESC;
