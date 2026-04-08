-- Atividade Aula 08 – Banco de Dados Relacional
-- Aluno: Lucas Monteiro Correia

CREATE TABLE clientes (
	id_clientes SERIAL PRIMARY KEY,
	nome        VARCHAR(100) NOT NULL,
	cpf         VARCHAR(11) UNIQUE NOT NULL,
	endereco    TEXT,
	telefone    VARCHAR(15)
);

CREATE TABLE contas (
	id_conta     SERIAL PRIMARY KEY,
	numero_conta VARCHAR(10) UNIQUE NOT NULL,
	saldo        DECIMAL(10, 2) DEFAULT 0,
	id_cliente   INT REFERENCES clientes(id_clientes) ON DELETE CASCADE
);

CREATE TABLE transacao (
	id_transacao             SERIAL PRIMARY KEY,
	id_conta                 INT REFERENCES contas(id_conta) ON DELETE CASCADE,
	tipo                     VARCHAR(15) CHECK (tipo IN ('Depósito', 'Saque', 'Transferência')),
	valor                    DECIMAL(10, 2) NOT NULL CHECK (valor > 0),
	data_transacao           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	destino_transferencia    INT REFERENCES contas(id_conta)
);

--

INSERT INTO clientes (nome, cpf, endereco, telefone) VALUES
('João Silva',      '12345678900', 'Rua A, 123', '11999990000'),
('Maria Oliveira',  '98765432100', 'Rua B, 456', '11988887777');

INSERT INTO contas (id_conta, numero_conta, saldo, id_cliente) VALUES
(1, '000123', 1500.00, 1),
(2, '000456', 2300.00, 2);

INSERT INTO transacao (id_conta, tipo, valor) VALUES
(1, 'Depósito',      500.00),
(2, 'Saque',         200.00),
(1, 'Transferência', 300.00);

SELECT * FROM clientes;

SELECT contas.numero_conta, clientes.nome
FROM contas
INNER JOIN clientes ON contas.id_cliente = clientes.id_clientes;

INSERT INTO clientes (nome, cpf, endereco, telefone) VALUES
('Lucas Monteiro', '98765432143', 'Rua C, 789', '11999995697');

INSERT INTO contas (id_conta, numero_conta, saldo, id_cliente) VALUES
(3, '000789', 1300.00, 3);

-- Realize uma transferência de R$ 100,00 da conta 000123 para a conta 000789.

BEGIN;

-- 1. Debita da conta de origem
UPDATE contas
SET saldo = saldo - 100.00
WHERE numero_conta = '000123';

-- 2. Credita na conta de destino
UPDATE contas
SET saldo = saldo + 100.00
WHERE numero_conta = '000789';

-- 3. Registra a transação na tabela transacao
INSERT INTO transacao (id_conta, tipo, valor, destino_transferencia)
VALUES (
    (SELECT id_conta FROM contas WHERE numero_conta = '000123'),
    'Transferência',
    100.00,
    (SELECT id_conta FROM contas WHERE numero_conta = '000789')
);

COMMIT;

SELECT * FROM contas;
