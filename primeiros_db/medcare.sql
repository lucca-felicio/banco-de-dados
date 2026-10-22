CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE especialidades (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);
CREATE TABLE medicos (
    id SERIAL PRIMARY KEY,
    especialidade_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    crm VARCHAR(20) UNIQUE NOT NULL,
    valor_consulta NUMERIC(10, 2) NOT NULL CHECK (valor_consulta > 0),
    CONSTRAINT fk_medico_especialidade FOREIGN KEY (especialidade_id) REFERENCES especialidades(id) ON DELETE RESTRICT
);
CREATE TABLE consultas (
    id SERIAL PRIMARY KEY,
    medico_id INT NOT NULL,
    paciente_id INT NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'Agendada' CHECK (status IN ('Agendada', 'Realizada', 'Cancelada')),
	CONSTRAINT fk_consulta_medico FOREIGN KEY (medico_id) REFERENCES medicos(id) ON DELETE RESTRICT,
    CONSTRAINT fk_consulta_paciente FOREIGN KEY (paciente_id) REFERENCES pacientes(id) ON DELETE CASCADE
);
CREATE TABLE exames_consulta (
    id SERIAL PRIMARY KEY,
    consulta_id INT NOT NULL,
    nome_exame VARCHAR(100) NOT NULL,
    valor_exame NUMERIC(10, 2) NOT NULL CHECK (valor_exame >= 0),
     CONSTRAINT fk_exame_consulta FOREIGN KEY (consulta_id) REFERENCES consultas(id) ON DELETE CASCADE
);
INSERT INTO especialidades (nome) VALUES 
('Cardiologia'),
('Pediatria'),
('Dermatologia');

INSERT INTO medicos (especialidade_id, nome, crm, valor_consulta) VALUES 
(1, 'Dra. Manuela Urbano', 'CRM/SC 123456', 350.00),
(2, 'Dr. Gabriel Demetrio', 'CRM/PR 678910', 250.00),
(3, 'Dra. Laura Urbano', 'CRM/SC 101112', 300.00);

INSERT INTO pacientes (nome, email, cpf, data_nascimento) VALUES 
('Aline Urbano', 'aline@email.com', '12345678910', '1983-03-28'),
('Mateus Urbano', 'mateus@email.com', '12345678911', '2078-07-05'),
('Marcio Demetrio', 'marcio@email.com', '12345678912', '1976-09-08');

INSERT INTO consultas (medico_id, paciente_id, data_hora, status) VALUES 
(1, 1, '2026-03-10 09:00:00', 'Realizada'),
(1, 3, '2026-03-10 10:30:00', 'Realizada'),
(2, 2, '2026-03-11 14:00:00', 'Agendada'),
(3, 1, '2026-03-12 11:00:00', 'Agendada'); 


INSERT INTO exames_consulta (consulta_id, nome_exame, valor_exame) VALUES 
(1, 'Eletrocardiograma', 120.00),
(1, 'Ecocardiograma', 250.00),
(2, 'Hemograma Completo', 45.00),
(3, 'Exame de Urina', 30.00);

CREATE VIEW vw_relacao1 as
SELECT 
    m.nome AS medico,
    m.crm,
    e.nome AS especialidade,
    m.valor_consulta
FROM medicos m
JOIN especialidades e ON m.especialidade_id = e.id
ORDER BY m.valor_consulta DESC;

CREATE VIEW vw_relacao2 as
SELECT 
    c.id AS consulta_id,
    c.data_hora,
    m.nome AS medico,
    e.nome AS especialidade,
    c.status
FROM consultas c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_id = m.id
JOIN especialidades e ON m.especialidade_id = e.id
WHERE p.nome = 'Aline Urbano'
ORDER BY c.data_hora ASC;

CREATE VIEW vw_relacao3 as
SELECT 
    c.id AS consulta_id,
    p.nome AS paciente,
    m.nome AS medico,
    m.valor_consulta,
    COALESCE(SUM(ex.valor_exame), 0.00) AS total_exames,
    (m.valor_consulta + COALESCE(SUM(ex.valor_exame), 0.00)) AS valor_total_atendimento
FROM consultas c
JOIN pacientes p ON c.paciente_id = p.id
JOIN medicos m ON c.medico_id = m.id
LEFT JOIN exames_consulta ex ON c.id = ex.consulta_id
GROUP BY c.id, p.nome, m.nome, m.valor_consulta
ORDER BY c.id;

CREATE VIEW vw_relacao4 as
SELECT 
    m.nome AS medico,
    m.crm,
    e.nome AS especialidade,
    m.valor_consulta
FROM medicos m
JOIN especialidades e ON m.especialidade_id = e.id
WHERE m.valor_consulta > 300.00;

CREATE VIEW vw_relacao5 as
SELECT 
    e.nome AS especialidade,
    COUNT(c.id) AS quantidade_consultas,
    COALESCE(SUM(m.valor_consulta), 0.00) AS faturamento_consultas
FROM especialidades e
JOIN medicos m ON e.id = m.especialidade_id
LEFT JOIN consultas c ON m.id = c.medico_id AND c.status = 'Realizada'
GROUP BY e.id, e.nome
ORDER BY faturamento_consultas DESC;
