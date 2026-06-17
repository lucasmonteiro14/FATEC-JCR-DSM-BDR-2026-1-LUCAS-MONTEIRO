-- =====================================================
-- BDR - Atividade Aula 14
-- Tema: Stored Procedures
-- Banco: biblioteca
-- =====================================================

-- EXERCÍCIO 1 – Inserir livro apenas se autor existir
CREATE OR REPLACE PROCEDURE inserir_livro_com_validacao(
    p_titulo       VARCHAR,
    p_paginas      INTEGER,
    p_ano          INTEGER,
    p_id_autor     INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe INTEGER;
BEGIN
    -- Verifica se o autor existe
    SELECT COUNT(*) INTO v_existe FROM autor WHERE id_autor = p_id_autor;

    IF v_existe = 0 THEN
        RAISE EXCEPTION 'Erro: autor com id % não existe.', p_id_autor;
    END IF;

    INSERT INTO livro (titulo, paginas, ano_publicacao, id_autor)
    VALUES (p_titulo, p_paginas, p_ano, p_id_autor);

    RAISE NOTICE 'Livro "%" inserido com sucesso.', p_titulo;
END;
$$;

-- Teste: autor existente
CALL inserir_livro_com_validacao('Dom Casmurro', 256, 1899, 1);

-- Teste: autor inexistente (deve gerar erro)
CALL inserir_livro_com_validacao('Livro Teste', 100, 2024, 9999);

-- =====================================================
-- EXERCÍCIO 2 – Atualizar páginas apenas se > 10
CREATE OR REPLACE PROCEDURE atualizar_paginas(
    p_id_livro INTEGER,
    p_paginas  INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_paginas <= 10 THEN
        RAISE EXCEPTION 'Erro: o número de páginas deve ser maior que 10. Valor informado: %.', p_paginas;
    END IF;

    UPDATE livro SET paginas = p_paginas WHERE id_livro = p_id_livro;

    RAISE NOTICE 'Páginas do livro id % atualizadas para %.', p_id_livro, p_paginas;
END;
$$;

-- Teste: valor válido
CALL atualizar_paginas(1, 350);

-- Teste: valor inválido (deve gerar erro)
CALL atualizar_paginas(1, 5);

-- =====================================================
-- EXERCÍCIO 3 – Excluir autor apenas se sem livros
CREATE OR REPLACE PROCEDURE excluir_autor(
    p_id_autor INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_livros INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_livros FROM livro WHERE id_autor = p_id_autor;

    IF v_livros > 0 THEN
        RAISE EXCEPTION 'Erro: o autor id % possui % livro(s) cadastrado(s). Exclua os livros primeiro.', p_id_autor, v_livros;
    END IF;

    DELETE FROM autor WHERE id_autor = p_id_autor;

    RAISE NOTICE 'Autor id % excluído com sucesso.', p_id_autor;
END;
$$;

-- Teste: autor com livros (deve gerar erro)
CALL excluir_autor(1);

-- =====================================================
-- EXERCÍCIO 4 – Procedure com cálculo: nome e média de páginas
CREATE OR REPLACE PROCEDURE relatorio_autor(
    p_id_autor INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_nome  VARCHAR;
    v_media NUMERIC;
BEGIN
    SELECT a.nome, AVG(l.paginas)
    INTO v_nome, v_media
    FROM autor a
    JOIN livro l ON a.id_autor = l.id_autor
    WHERE a.id_autor = p_id_autor
    GROUP BY a.nome;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Autor id % não encontrado ou sem livros.', p_id_autor;
    END IF;

    RAISE NOTICE 'Autor: % | Média de páginas: %', v_nome, ROUND(v_media, 2);

    -- Também retorna via SELECT para visualização
    SELECT v_nome AS autor, ROUND(v_media, 2) AS media_paginas;
END;
$$;

-- Teste
CALL relatorio_autor(1);

-- =====================================================
-- EXERCÍCIO 5 – DESAFIO: Inserir com todas as validações
CREATE OR REPLACE PROCEDURE inserir_livro_completo(
    p_titulo   VARCHAR,
    p_paginas  INTEGER,
    p_ano      INTEGER,
    p_id_autor INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existe INTEGER;
BEGIN
    -- Validação 1: páginas > 0
    IF p_paginas <= 0 THEN
        RAISE EXCEPTION 'Erro: número de páginas deve ser maior que 0. Informado: %.', p_paginas;
    END IF;

    -- Validação 2: título não pode ser vazio
    IF TRIM(p_titulo) = '' OR p_titulo IS NULL THEN
        RAISE EXCEPTION 'Erro: o título não pode ser vazio.';
    END IF;

    -- Validação 3: autor deve existir
    SELECT COUNT(*) INTO v_existe FROM autor WHERE id_autor = p_id_autor;
    IF v_existe = 0 THEN
        RAISE EXCEPTION 'Erro: autor com id % não encontrado.', p_id_autor;
    END IF;

    -- Tudo válido: inserir
    INSERT INTO livro (titulo, paginas, ano_publicacao, id_autor)
    VALUES (p_titulo, p_paginas, p_ano, p_id_autor);

    RAISE NOTICE 'Livro "%" inserido com sucesso!', p_titulo;
END;
$$;

-- Teste: válido
CALL inserir_livro_completo('Vidas Secas', 176, 1938, 1);

-- Teste: páginas negativas
CALL inserir_livro_completo('Teste Inválido', -10, 2024, 1);

-- Teste: título vazio
CALL inserir_livro_completo('', 200, 2024, 1);

-- Teste: autor inexistente
CALL inserir_livro_completo('Livro Órfão', 200, 2024, 9999);

-- =====================================================
-- EXERCÍCIO 6 – DESAFIO: Demonstrar bloqueio de páginas negativas
CALL inserir_livro_completo('Livro com páginas negativas', -50, 2024, 1);
-- Resultado esperado: RAISE EXCEPTION bloqueando a inserção
