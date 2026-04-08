-- Atividade Aula 05 – Banco de Dados Relacional
-- Aluno: Lucas Monteiro Correia

SELECT * FROM CategoriaUsuario;
SELECT * FROM Usuario;
SELECT * FROM Localizacao;
SELECT * FROM TipoEvento;
SELECT * FROM Evento;
SELECT * FROM Relato;
SELECT * FROM Alerta;

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


INSERT INTO CategoriaUsuario (nome, nivel_acesso, descricao) VALUES
('Administrador', 3, 'Acesso total'),
('Operador', 2, 'Acesso limitado'),
('Estágiario', 1, 'Acesso restringido');

INSERT INTO Usuario (nome, email, senhaHash, idCategoria) VALUES
('João Miguel', 'joao@exemplo.com', 'Senha123', 3),
('Carlos Emanuel', 'Manuel@exemplo.com', 'Senha456', 2),
('Ronaldo Ingles', 'Ronald@exemplo.com', 'Senha789', 1);

INSERT INTO Localizacao (latitude, longitude, cidade, estado) VALUES
('-12.9777', '-38.5016', 'Salvador', 'BA'),
('-25.4284', '-49.2733', 'Curitiba', 'PR'),
('-3.7319',  '-38.5267', 'Fortaleza', 'CE');

INSERT INTO TipoEvento (nome, descricao) VALUES
('Alerta de Chuva', 'Aviso sobre chuvas torrenciais'),
('Alerta de Tempestade', 'Aviso sobre tempestades intensas'),
('Alerta de Granizo', 'Aviso sobre chuva forte de granizo');

INSERT INTO Evento (titulo, descricao, dataHora, status, idTipoEvento, idLocalizacao) VALUES
('Forte tempestade', 'Tempestade prevista para a tarde', '2026-03-03 16:00:00', 'Ativo', 2, 3),
('Risco de Chuva', 'Chuva torrencial prevista durante a noite', '2026-03-07 21:00:00', 'Ativo', 1, 2),
('Risco de Granizo', 'Forte risco de granizo previsto pela manhã', '2026-03-05 06:00:00', 'Ativo', 3, 1);

SELECT nome FROM Usuario;

SELECT cidade FROM Localizacao;

SELECT titulo, status FROM Evento
WHERE status = 'Ativo';

SELECT nome, idCategoria FROM Usuario
WHERE idCategoria = 3;
