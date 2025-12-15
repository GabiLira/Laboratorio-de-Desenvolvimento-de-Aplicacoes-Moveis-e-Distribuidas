CREATE TABLE IF NOT EXISTS usuario (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(100) NOT NULL,
    tipo INT NOT NULL DEFAULT 0, -- 0: Cliente, 1: Entregador
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO usuario (nome, email, senha, tipo, data_criacao)
VALUES ('Gabriel', 'gabriel@gmail.com','123456', 0, '2025-06-11 12:00:00');

CREATE TABLE IF NOT EXISTS pedidos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    origem VARCHAR (200) NOT NULL,
    destino VARCHAR (200) NOT NULL,
    situacao INT NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT NOT NULL REFERENCES usuario(id)
);

INSERT INTO pedidos (nome, origem, destino, situacao, data_criacao, id_usuario)
VALUES ('Rifle .50', '-23.5505,-46.6333', '-23.5505,-46.6333', 1, '2025-06-11 12:00:00', 1);

CREATE TABLE IF NOT EXISTS rastreamento (
    id SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL REFERENCES pedidos(id),
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO rastreamento (id_pedido, latitude, longitude, timestamp)
VALUES (1, -23.5505, -46.6333, '2025-06-11 12:00:00');