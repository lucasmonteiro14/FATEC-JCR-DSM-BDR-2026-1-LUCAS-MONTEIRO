-- Exc Aula 2

CREATE TABLE focos_calor (
  id SERIAL PRIMARY KEY,
  estado VARCHAR(50) NOT NULL,
  bioma VARCHAR(50) NOT NULL,
  data_ocorrencia DATE NOT NULL
);

INSERT INTO focos_calor (estado, bioma, data_ocorrencia) VALUES
('Amazonas', 'Amazônia', '2025-02-01'),
('Mato Grosso', 'Cerrado', '2025-02-03'),
('Pará', 'Amazônia', '2025-02-05');

SELECT * FROM focos_calor;
