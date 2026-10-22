CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    categoria_id INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    preco NUMERIC(10, 2) NOT NULL CHECK (preco > 0),
    quantidade_estoque INT NOT NULL DEFAULT 0 CHECK (quantidade_estoque >= 0),
    
    CONSTRAINT fk_produto_categoria 
        FOREIGN KEY (categoria_id) 
        REFERENCES categorias(id) 
        ON DELETE RESTRICT
);

CREATE TABLE pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pendente' CHECK (status IN ('Pendente', 'Pago', 'Enviado', 'Cancelado')),
    
    CONSTRAINT fk_pedido_cliente 
        FOREIGN KEY (cliente_id) 
        REFERENCES clientes(id) 
        ON DELETE CASCADE
);

CREATE TABLE itens_pedido (
    pedido_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unitario NUMERIC(10, 2) NOT NULL CHECK (preco_unitario > 0),
    
    PRIMARY KEY (pedido_id, produto_id),
    CONSTRAINT fk_item_pedido FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    CONSTRAINT fk_item_produto FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE RESTRICT
);

INSERT INTO categorias (nome) VALUES 
('Informática'),
('Comida'),
('Roupas');

INSERT INTO produtos (categoria_id, nome, preco, quantidade_estoque) VALUES 
(1, 'Mouse Gamer Redragon', 150.00, 25),
(1, 'Teclado Mecânico Logitech', 350.00, 8),
(2, 'Batata kg', 20.00, 50),
(2, 'Cenoura kg', 15.00, 40),
(3, 'Blusa', 30.00, 15);

INSERT INTO clientes (nome, email, cpf) VALUES 
('Manuela', 'manuela@email.com', '12345678910'),
('Gabriel', 'gabriel@email.com', '12345678911'),
('Laura', 'laura@email.com', '12345678912');

INSERT INTO pedidos (cliente_id, status) VALUES 
(1, 'Pago'),
(1, 'Pendente'),
(1, 'Enviado'),
(1, 'Cancelado'),
(2, 'Pago'),
(2, 'Pendente'),
(2, 'Enviado'),
(2, 'Cancelado'),
(3, 'Pago'),
(3, 'Pendente'),
(3, 'Enviado'),
(3, 'Cancelado');

-INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES 
(1, 1, 3, 150.00), 
(1, 2, 3, 350.00), 
(2, 3, 3, 20.00),
(2, 4, 3, 15.00), 
(3, 5, 3, 30.00);

CREATE VIEW vw_relacao1 as
SELECT 
    p.nome AS produto,
    c.nome AS categoria,
    p.preco,
    p.quantidade_estoque
FROM produtos p
INNER JOIN categorias c ON p.categoria_id = c.id
ORDER BY p.preco DESC;

CREATE VIEW vw_relacao2 as
SELECT 
    ped.id AS pedido_id,
    cli.nome AS cliente,
    ped.data_pedido,
    ped.status
FROM pedidos ped
INNER JOIN clientes cli ON ped.cliente_id = cli.id
WHERE cli.nome = 'Manuela';

CREATE VIEW vw_relacao3 as
SELECT 
    ped.id AS pedido_id,
    cli.nome AS cliente,
    SUM(item.quantidade * item.preco_unitario) AS valor_total_pedido
FROM pedidos ped
INNER JOIN clientes cli ON ped.cliente_id = cli.id
INNER JOIN itens_pedido item ON ped.id = item.pedido_id
GROUP BY ped.id, cli.nome
ORDER BY ped.id;

CREATE VIEW vw_relacao4 as
SELECT 
    nome AS produto,
    quantidade_estoque
FROM produtos
WHERE quantidade_estoque < 10
ORDER BY quantidade_estoque ASC;

CREATE VIEW vw_relacao5 as
SELECT 
    cat.nome AS categoria,
    COALESCE(SUM(item.quantidade * item.preco_unitario), 0.00) AS total_faturado
FROM categorias cat
LEFT JOIN produtos prod ON cat.id = prod.categoria_id
LEFT JOIN itens_pedido item ON prod.id = item.produto_id
GROUP BY cat.id, cat.nome
ORDER BY total_faturado DESC;
