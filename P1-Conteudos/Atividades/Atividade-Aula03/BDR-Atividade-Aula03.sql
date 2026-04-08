-- Atividade Aula 03 – Banco de Dados Relacional
-- Aluno: Lucas Monteiro Correia
-- Implementação do diagrama de locadora de veículos

CREATE TABLE cliente (
  id        SERIAL PRIMARY KEY,
  nome      VARCHAR(100),
  cpf       CHAR(11),
  telefone  VARCHAR(20)
);

CREATE TABLE carro (
  placa          VARCHAR(7) PRIMARY KEY,
  modelo         VARCHAR(100),
  montadora      VARCHAR(100),
  ano_fabricacao INTEGER
);

CREATE TABLE aluguel (
  id           SERIAL PRIMARY KEY,
  cliente_id   INTEGER NOT NULL REFERENCES cliente(id),
  carro_placa  VARCHAR(7) NOT NULL REFERENCES carro(placa),
  data_inicio  TIMESTAMP NOT NULL,
  data_fim     TIMESTAMP
);
