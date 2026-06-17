-- =====================================================
-- BDR - Atividade Aula 12
-- Tema: Índices
-- =====================================================

-- Criação das tabelas
DROP TABLE IF EXISTS carro, pessoa;

CREATE TABLE IF NOT EXISTS pessoa (
    id_pessoa INTEGER PRIMARY KEY,
    nome      VARCHAR(100) NOT NULL,
    nascimento DATE
);

CREATE TABLE IF NOT EXISTS carro (
    id_carro  INTEGER PRIMARY KEY,
    placa     CHAR(7) NOT NULL,
    ano       INTEGER,
    id_pessoa INTEGER NOT NULL,
    FOREIGN KEY (id_pessoa) REFERENCES pessoa(id_pessoa) ON DELETE CASCADE
);

-- Carregar dados (ajustar caminho conforme seu computador)
COPY pessoa (id_pessoa, nome, nascimento)
FROM 'C:/caminho/aula3_pessoa.csv'
DELIMITER ','
CSV HEADER;

COPY carro (id_carro, placa, ano, id_pessoa)
FROM 'C:/caminho/aula3_carro.csv'
DELIMITER ','
CSV HEADER;

-- =====================================================
-- EXERCÍCIO 1 – Índice B-tree na coluna nome
-- =====================================================

-- Parte A: Consulta sem índice
EXPLAIN ANALYZE
SELECT * FROM pessoa WHERE nome = 'Ana Silva';

EXPLAIN ANALYZE
SELECT * FROM pessoa WHERE nome = 'João Santos';

-- Parte B: Criação do índice
CREATE INDEX idx_pessoa_nome ON pessoa (nome);

-- Parte C: Consulta com índice
EXPLAIN ANALYZE
SELECT * FROM pessoa WHERE nome = 'Ana Silva';

EXPLAIN ANALYZE
SELECT * FROM pessoa WHERE nome = 'João Santos';

-- Parte D – Respostas:
-- Antes do índice: Seq Scan (varredura sequencial em toda a tabela)
-- Após o índice: Index Scan usando idx_pessoa_nome (acesso direto)
-- Houve redução significativa no tempo de execução
-- O índice foi utilizado em ambos os nomes (alta seletividade: poucos registros por nome)

-- =====================================================
-- EXERCÍCIO 2 – Seletividade e decisão do otimizador
-- =====================================================

-- Parte A: Remove índice anterior e testa sem índice por nascimento
DROP INDEX IF EXISTS idx_pessoa_nome;

EXPLAIN ANALYZE
SELECT * FROM pessoa WHERE nascimento >= DATE '1970-01-01';

-- Parte B: Cria índice em nascimento
CREATE INDEX idx_pessoa_nascimento ON pessoa (nascimento);

-- Parte C: Repete consulta
EXPLAIN ANALYZE
SELECT * FROM pessoa WHERE nascimento >= DATE '1970-01-01';

-- Parte D – Respostas:
-- O índice pode NÃO ter sido utilizado pelo PostgreSQL
-- O otimizador opta por Seq Scan quando a consulta retorna muitos registros
-- (baixa seletividade: ex: > 50% dos registros), pois é mais eficiente que
-- acessar o índice linha por linha quando há grande volume de resultados.

-- =====================================================
-- EXERCÍCIO 3 – Índice Composto e Ordem das Colunas
-- =====================================================

DROP INDEX IF EXISTS idx_pessoa_nascimento;

-- Parte A: Sem índice composto
EXPLAIN ANALYZE
SELECT * FROM pessoa
WHERE nascimento >= DATE '2000-01-01' AND nome = 'Ana Silva';

-- Parte B: Cria índice composto (nascimento, nome)
CREATE INDEX idx_pessoa_nascimento_nome ON pessoa (nascimento, nome);

-- Parte C: Com índice composto
EXPLAIN ANALYZE
SELECT * FROM pessoa
WHERE nascimento >= DATE '2000-01-01' AND nome = 'Ana Silva';

-- Parte D: Consulta somente por nome (sem usar a 1ª coluna do índice)
EXPLAIN ANALYZE
SELECT * FROM pessoa WHERE nome = 'Ana Silva';

-- Parte E – Respostas:
-- Antes: Seq Scan
-- Após: Index Scan usando idx_pessoa_nascimento_nome
-- Consulta só por nome NÃO usa o índice composto (nome é a 2ª coluna)
-- A ordem importa: o índice começa pela 1ª coluna; sem ela na cláusula WHERE,
-- o índice composto não pode ser usado eficientemente.

-- =====================================================
-- EXERCÍCIO 4 – Múltiplos Índices Simples (BitmapAnd)
-- =====================================================

DROP INDEX IF EXISTS idx_pessoa_nascimento_nome;

CREATE INDEX idx_pessoa_nascimento ON pessoa (nascimento);
CREATE INDEX idx_pessoa_nome ON pessoa (nome);

EXPLAIN ANALYZE
SELECT * FROM pessoa
WHERE nascimento >= DATE '2000-01-01' AND nome = 'Ana Silva';

-- Parte C – Respostas:
-- O PostgreSQL pode usar os dois índices via BitmapAnd
-- BitmapAnd: cada índice gera um bitmap de páginas, depois faz AND entre eles
-- O plano efetivamente: BitmapOr/And → Bitmap Heap Scan nas páginas resultantes
-- Resultado: intersecção eficiente dos dois bitmaps antes de acessar o heap

-- =====================================================
-- EXERCÍCIO 5 – Índice para Filtro por Intervalo em carro
-- =====================================================

DROP INDEX IF EXISTS idx_pessoa_nascimento;
DROP INDEX IF EXISTS idx_pessoa_nome;

-- Sem índice
EXPLAIN ANALYZE
SELECT * FROM carro WHERE ano BETWEEN 2015 AND 2020;

-- Índice B-tree em ano (ideal para intervalos)
CREATE INDEX idx_carro_ano ON carro (ano);

-- Com índice
EXPLAIN ANALYZE
SELECT * FROM carro WHERE ano BETWEEN 2015 AND 2020;

-- =====================================================
-- EXERCÍCIO 6 – Índice para otimização de JOIN
-- =====================================================

DROP INDEX IF EXISTS idx_carro_ano;

-- Sem índice
EXPLAIN ANALYZE
SELECT p.nome, c.placa
FROM pessoa p
JOIN carro c ON p.id_pessoa = c.id_pessoa
WHERE p.nome = 'Ana Silva';

-- Índices: nome em pessoa (filtro WHERE) e id_pessoa em carro (chave estrangeira JOIN)
CREATE INDEX idx_pessoa_nome ON pessoa (nome);
CREATE INDEX idx_carro_id_pessoa ON carro (id_pessoa);

-- Com índices
EXPLAIN ANALYZE
SELECT p.nome, c.placa
FROM pessoa p
JOIN carro c ON p.id_pessoa = c.id_pessoa
WHERE p.nome = 'Ana Silva';

-- =====================================================
-- EXERCÍCIO 7 – Índice Composto em JOIN com Filtro
-- =====================================================

DROP INDEX IF EXISTS idx_pessoa_nome;
DROP INDEX IF EXISTS idx_carro_id_pessoa;

-- Sem índices
EXPLAIN ANALYZE
SELECT p.nome, c.placa, c.ano
FROM pessoa p
JOIN carro c ON p.id_pessoa = c.id_pessoa
WHERE p.nascimento >= DATE '1980-01-01' AND c.ano >= 2018;

-- Índice composto em pessoa (nascimento para filtro, id_pessoa para JOIN)
CREATE INDEX idx_pessoa_nasc ON pessoa (nascimento);
-- Índice composto em carro (id_pessoa para JOIN, ano para filtro)
CREATE INDEX idx_carro_id_ano ON carro (id_pessoa, ano);

-- Com índices
EXPLAIN ANALYZE
SELECT p.nome, c.placa, c.ano
FROM pessoa p
JOIN carro c ON p.id_pessoa = c.id_pessoa
WHERE p.nascimento >= DATE '1980-01-01' AND c.ano >= 2018;

-- Justificativa: índice simples em pessoa.nascimento (filtro de intervalo);
-- índice composto em carro(id_pessoa, ano) cobre tanto o JOIN quanto o filtro de ano.

-- =====================================================
-- EXERCÍCIO 8 – Índice GiST
-- =====================================================

DROP INDEX IF EXISTS idx_pessoa_nasc;
DROP INDEX IF EXISTS idx_carro_id_ano;

-- Parte A: Sem índice GiST
EXPLAIN ANALYZE
SELECT * FROM pessoa
WHERE nascimento BETWEEN DATE '1980-01-01' AND DATE '1990-12-31';

-- Parte B: Habilita extensão e cria índice GiST
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE INDEX idx_pessoa_nascimento_gist ON pessoa USING GIST (nascimento);

-- Verifica criação
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'pessoa';

-- Parte C: Com índice GiST
EXPLAIN ANALYZE
SELECT * FROM pessoa
WHERE nascimento BETWEEN DATE '1980-01-01' AND DATE '1990-12-31';

-- Parte D – Respostas:
-- Antes: Seq Scan
-- GiST foi utilizado após a criação
-- Houve melhora no tempo de execução para consultas por intervalo
