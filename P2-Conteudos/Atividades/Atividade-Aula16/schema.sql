-- =====================================================
-- BDR - Atividade Aula 16
-- Tema: Triggers
-- Banco: biblioteca
-- =====================================================

-- EXERCÍCIO 1 – Trigger: bloquear exclusão de livros com estoque
CREATE OR REPLACE FUNCTION bloquear_exclusao()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.quantidade > 0 THEN
        RAISE EXCEPTION
            'Exclusão bloqueada: o livro "%" ainda possui % exemplar(es) disponível(is).',
            OLD.titulo, OLD.quantidade;
    END IF;
    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_bloquear_exclusao
BEFORE DELETE ON livro
FOR EACH ROW
EXECUTE FUNCTION bloquear_exclusao();

-- Teste: tentar deletar livro com estoque (deve falhar)
-- DELETE FROM livro WHERE id_livro = 1;

-- Teste: deletar livro sem estoque (deve funcionar)
-- UPDATE livro SET quantidade = 0 WHERE id_livro = 1;
-- DELETE FROM livro WHERE id_livro = 1;

-- =====================================================
-- EXERCÍCIO 2 – Trigger: registrar exclusões no log

-- Tabela de log (caso ainda não exista)
CREATE TABLE IF NOT EXISTS log_exclusao_livro (
    id_log      SERIAL PRIMARY KEY,
    titulo      VARCHAR(200),
    data_hora   TIMESTAMP DEFAULT NOW(),
    mensagem    TEXT
);

CREATE OR REPLACE FUNCTION log_exclusao_livro()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO log_exclusao_livro (titulo, data_hora, mensagem)
    VALUES (
        OLD.titulo,
        NOW(),
        FORMAT('Livro "%s" foi removido do sistema em %s.', OLD.titulo, NOW())
    );
    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_log_exclusao
AFTER DELETE ON livro
FOR EACH ROW
EXECUTE FUNCTION log_exclusao_livro();

-- Verificar log após exclusão:
-- SELECT * FROM log_exclusao_livro;

-- =====================================================
-- EXERCÍCIO 3 – Trigger: controle de estoque máximo (limite 100)

CREATE OR REPLACE FUNCTION validar_limite_estoque()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.quantidade > 100 THEN
        RAISE EXCEPTION
            'Atualização bloqueada: quantidade % excede o limite máximo de 100 exemplares.',
            NEW.quantidade;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_limite
BEFORE UPDATE ON livro
FOR EACH ROW
EXECUTE FUNCTION validar_limite_estoque();

-- Teste: atualização válida
-- UPDATE livro SET quantidade = 50 WHERE id_livro = 1;

-- Teste: atualização inválida (deve falhar)
-- UPDATE livro SET quantidade = 200 WHERE id_livro = 1;

-- =====================================================
-- EXERCÍCIO 4 – Análise: BEFORE vs AFTER

/*
a) Diferença entre BEFORE e AFTER:
   - BEFORE: executada antes da operação DML (INSERT/UPDATE/DELETE).
     Pode modificar ou cancelar a operação (RETURN NULL ou RAISE EXCEPTION).
   - AFTER: executada após a operação DML, quando os dados já foram alterados.
     Usada para ações secundárias como logs, notificações ou atualizações em outras tabelas.

b) Qual usar para validação:
   BEFORE — pois pode impedir a operação antes que ela ocorra no banco.
   Uma trigger BEFORE pode rejeitar a operação com RAISE EXCEPTION ou retornar NULL.

c) Qual usar para auditoria/log:
   AFTER — pois a operação já foi confirmada no banco, garantindo que o log
   só registre ações que de fato ocorreram. Também tem acesso aos valores OLD e NEW.

d) Por que a ordem de execução importa:
   Em bancos reais, validações BEFORE garantem integridade antes de qualquer gravação.
   Se o log fosse BEFORE e a operação falhasse depois, teríamos registros falsos.
   Se a validação fosse AFTER, os dados inválidos já teriam sido gravados.
   A sequência correta é: validar (BEFORE) → executar → registrar (AFTER).
*/

-- =====================================================
-- EXERCÍCIO 5 – Reflexão: Integridade e Automação

/*
a) Riscos de remover triggers e deixar validações apenas na aplicação:
   - Acesso direto ao banco (psql, scripts, outros sistemas) burla todas as regras.
   - Inconsistência quando há múltiplas aplicações acessando o mesmo banco.
   - Erros humanos em operações manuais de manutenção.
   - Dados corrompidos difíceis de rastrear sem histórico de auditoria.

b) Vantagens de manter regras no banco:
   - Regras centralizadas: valem para qualquer acesso, independente da origem.
   - Consistência garantida: nenhuma inserção/atualização burla as regras.
   - Reduz duplicação de lógica entre sistemas diferentes.
   - Facilita auditorias e conformidade com regulamentações.

c) Como triggers ajudam na integridade e consistência:
   - Validam dados antes ou após cada operação DML automaticamente.
   - Mantêm logs de auditoria sem depender da aplicação.
   - Implementam regras de negócio complexas diretamente no banco.
   - Garantem que relações entre tabelas sejam sempre respeitadas.

d) Exemplo real de uso em sistemas corporativos:
   Em sistemas bancários, uma trigger BEFORE UPDATE em contas correntes verifica
   se o saldo resultante de uma transferência não ficará negativo antes de confirmar
   a operação. Uma trigger AFTER INSERT em transações registra automaticamente
   o evento em uma tabela de auditoria para conformidade com o Banco Central.
*/
