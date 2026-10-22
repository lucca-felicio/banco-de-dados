CREATE TABLE leitores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE livros (
    id SERIAL PRIMARY KEY,
    categoria_id INT REFERENCES categorias(id),
    titulo VARCHAR(150) NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    taxa_diaria DECIMAL(10,2) CHECK (taxa_diaria > 0) NOT NULL,
    disponivel BOOLEAN DEFAULT TRUE
);

CREATE TABLE emprestimos (
    id SERIAL PRIMARY KEY,
    leitor_id INT REFERENCES leitores(id),
    data_emprestimo TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Devolvido', 'Atrasado'))
);

CREATE TABLE itens_emprestimo (
    id SERIAL PRIMARY KEY,
    emprestimo_id INT REFERENCES emprestimos(id),
    livro_id INT REFERENCES livros(id),
    quantidade INT CHECK (quantidade > 0) NOT NULL,
    valor_diaria DECIMAL(10,2) CHECK (valor_diaria >= 0) NOT NULL
);


INSERT INTO leitores (nome, email, cpf, telefone) VALUES 
('Manuela', 'manuela@email.com', '11111111111', '48123456789'),
('Gabriel', 'gabriel@email.com', '22222222222', '48123456789'),
('Laura', 'laura@email.com', '33333333333', '48123456789');

INSERT INTO categorias (nome) VALUES 
('Ficção'), ('História'), ('Tecnologia');

INSERT INTO livros (categoria_id, titulo, isbn, taxa_diaria, disponivel) VALUES 
(1, 'O Senhor dos Anéis', '101010101010', 7.50, TRUE),
(1, '1984', '100100100100', 4.00, TRUE),
(3, 'Entendendo Algoritmos', '110110110110', 6.00, TRUE);

INSERT INTO emprestimos (leitor_id, status) VALUES 
(1, 'Devolvido'), (1, 'Ativo'), (2, 'Devolvido'), (3, 'Atrasado');

INSERT INTO itens_emprestimo (emprestimo_id, livro_id, quantidade, valor_diaria) VALUES 
(1, 1, 2, 7.50),
(2, 2, 1, 4.00),
(3, 3, 3, 6.00),
(4, 1, 1, 7.50);


CREATE VIEW vw_acervo_ordenado AS
SELECT 
l.titulo AS livro, 
l.isbn, 
l.taxa_diaria,
c.nome AS categoria
FROM livros l
JOIN categorias c ON l.categoria_id = c.id
ORDER BY l.taxa_diaria DESC;

CREATE VIEW vw_emprestimos_carlos AS
SELECT 
e.id AS emprestimo_id, 
e.data_emprestimo, 
li.titulo AS livro, 
i.quantidade, 
e.status
FROM emprestimos e
JOIN leitores le ON e.leitor_id = le.id
JOIN itens_emprestimo i ON e.id = i.emprestimo_id
JOIN livros li ON i.livro_id = li.id
WHERE le.nome = 'Manuela';

CREATE VIEW vw_total_emprestimos AS
SELECT 
e.id AS emprestimo_id, 
l.nome AS leitor, 
SUM(i.quantidade * i.valor_diaria) AS valor_total
FROM emprestimos e
JOIN leitores l ON e.leitor_id = l.id
JOIN itens_emprestimo i ON e.id = i.emprestimo_id
GROUP BY e.id, l.nome;

SELECT 
l.* 
FROM livros l
JOIN categorias c ON l.categoria_id = c.id
WHERE c.nome = 'Ficção' AND l.taxa_diaria > 5.00 AND l.disponivel = TRUE;

CREATE VIEW vw_faturamento_por_categoria AS
SELECT 
c.nome AS categoria, 
SUM(i.quantidade * i.valor_diaria) AS faturamento_total
FROM itens_emprestimo i
JOIN emprestimos e ON i.emprestimo_id = e.id
JOIN livros l ON i.livro_id = l.id
JOIN categorias c ON l.categoria_id = c.id
WHERE e.status = 'Devolvido'
GROUP BY c.nome;
