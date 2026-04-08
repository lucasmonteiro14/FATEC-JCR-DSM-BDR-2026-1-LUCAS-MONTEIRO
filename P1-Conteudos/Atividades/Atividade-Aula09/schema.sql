-- Atividade Aula 09 – Banco de Dados Relacional
-- Aluno: Lucas Monteiro Correia

SELECT
    evento.titulo AS titulo_do_evento,
    tipoevento.nome AS nome_do_tipo_evento
FROM
    evento
    INNER JOIN tipoevento ON evento.idtipoevento = tipoevento.idtipoevento;

SELECT
    evento.titulo AS titulo_do_evento,
    localizacao.cidade,
    localizacao.estado AS sigla_estado
FROM
    evento
    INNER JOIN localizacao ON evento.idlocalizacao = localizacao.idlocalizacao;

SELECT
    evento.titulo AS titulo_do_evento,
    tipoevento.nome AS tipo_evento,
    localizacao.cidade
FROM
    localizacao
    LEFT JOIN evento ON evento.idlocalizacao = localizacao.idlocalizacao
    LEFT JOIN tipoevento ON evento.idtipoevento = tipoevento.idtipoevento;

SELECT
    evento.titulo AS titulo_do_evento,
    tipoevento.nome AS tipo_evento,
    localizacao.cidade
FROM
    evento
    RIGHT JOIN tipoevento ON evento.idtipoevento = tipoevento.idtipoevento
    RIGHT JOIN localizacao ON evento.idlocalizacao = localizacao.idlocalizacao;

SELECT
    localizacao.cidade AS cidade,
    COUNT(evento.titulo) AS quantidade_de_eventos
FROM
    localizacao
    LEFT JOIN evento ON evento.idlocalizacao = localizacao.idlocalizacao
GROUP BY
    localizacao.cidade;
