-- Atividade Aula 06 – Banco de Dados Relacional
-- Aluno: Lucas Monteiro Correia

SELECT * FROM Alerta;
SELECT * FROM Evento;
SELECT * FROM TipoEvento;
SELECT * FROM Localizacao;
SELECT * FROM Usuario;
SELECT * FROM Relato;
SELECT * FROM CategoriaUsuario;

--

CREATE TABLE CategoriaUsuario (
    idCategoria SERIAL PRIMARY KEY,
    nome        VARCHAR(50) NOT NULL,
    nivel_acesso INT NOT NULL,
    descricao   VARCHAR(200),
    CONSTRAINT NomeCategoria UNIQUE (nome)
    -- Haverá apenas um nome para cada tipo de categoria (ex.administrador, operador, etc)
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

--

INSERT INTO Usuario (nome, email, senhahash, idcategoria) VALUES
('Koen Ramos', 'Koen@email.com', 'hash$4', 2),
('Selene Kamo', 'Selen@email.com', 'hash$5', 1);

SELECT nome, email, idcategoria FROM Usuario
WHERE idcategoria = 1
ORDER BY nome ASC;

SELECT titulo, datahora FROM Evento
ORDER BY datahora DESC;

SELECT nome, email, idcategoria FROM Usuario
ORDER BY idcategoria DESC
LIMIT 3;
