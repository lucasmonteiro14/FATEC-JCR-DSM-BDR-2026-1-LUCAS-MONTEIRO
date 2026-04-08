-- Atividade Aula 04 – Banco de Dados Relacional
-- Aluno: Lucas Monteiro Correia

-- Remoção das tabelas existentes
DROP TABLE IF EXISTS Alerta      CASCADE;
DROP TABLE IF EXISTS Relato      CASCADE;
DROP TABLE IF EXISTS Evento      CASCADE;
DROP TABLE IF EXISTS TipoEvento  CASCADE;
DROP TABLE IF EXISTS Localizacao CASCADE;
DROP TABLE IF EXISTS Usuario     CASCADE;
DROP TABLE IF EXISTS CategoriaUsuario CASCADE;

-- Criação das tabelas

CREATE TABLE CategoriaUsuario (
    idCategoria SERIAL PRIMARY KEY,
    nome        VARCHAR(50) NOT NULL,
    nivel_acesso INT NOT NULL,
    descricao   VARCHAR(200),
    CONSTRAINT NomeCategoria UNIQUE (nome)
);

CREATE TABLE Usuario (
    idUsuario SERIAL PRIMARY KEY,
    nome      VARCHAR(50),
    email     VARCHAR(50),
    senhaHash TEXT NOT NULL,
    idCategoria INT REFERENCES CategoriaUsuario(idCategoria)
);

CREATE TABLE Localizacao (
    idLocalizacao SERIAL PRIMARY KEY,
    latitude      DECIMAL(5,3),
    longitude     DECIMAL(5,3),
    cidade        VARCHAR(50),
    estado        CHAR(2)
);

CREATE TABLE TipoEvento (
    idTipoEvento SERIAL PRIMARY KEY,
    nome         VARCHAR(30),
    descricao    VARCHAR(50)
);

CREATE TABLE Evento (
    idEvento      SERIAL PRIMARY KEY,
    titulo        VARCHAR(50),
    descricao     VARCHAR(50),
    dataHora      TIMESTAMP,
    status        VARCHAR(10),
    idTipoEvento  INT REFERENCES TipoEvento(idTipoEvento),
    idLocalizacao INT REFERENCES Localizacao(idLocalizacao)
);

CREATE TABLE Relato (
    idRelato  SERIAL PRIMARY KEY,
    texto     VARCHAR(50),
    dataHora  TIMESTAMP,
    idEvento  INT REFERENCES Evento(idEvento),
    idUsuario INT REFERENCES Usuario(idUsuario)
);

CREATE TABLE Alerta (
    idAlerta SERIAL PRIMARY KEY,
    mensagem VARCHAR(50),
    dataHora TIMESTAMP,
    nivel    VARCHAR(30),
    idEvento INT REFERENCES Evento(idEvento)
);

-- SELECT * FROM Alerta;
-- SELECT * FROM Evento;
-- SELECT * FROM TipoEvento;
-- SELECT * FROM Localizacao;
-- SELECT * FROM Usuario;
-- SELECT * FROM Relato;
-- SELECT * FROM CategoriaUsuario;
