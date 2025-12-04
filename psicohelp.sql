-- psicohelp_fix.sql
DROP DATABASE IF EXISTS psicohelp;
CREATE DATABASE psicohelp;
USE psicohelp;

-- Tabela de Usuários
CREATE TABLE Usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    tipo ENUM('cliente', 'psicologo', 'moderador') NOT NULL DEFAULT 'cliente',
    telefone VARCHAR(20),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('ativo', 'inativo') DEFAULT 'ativo'
);

-- Tabela de Clientes
CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT UNIQUE NOT NULL,
    data_nascimento DATE,
    genero VARCHAR(20),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabela de Psicólogos
CREATE TABLE Psicologo (
    id_psicologo INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT UNIQUE NOT NULL,
    CRP VARCHAR(20) NOT NULL,
    especialidade VARCHAR(100),
    formacao TEXT,
    abordagem VARCHAR(100),
    experiencia INT DEFAULT 0,
    descricao TEXT,
    status ENUM('pendente', 'ativo', 'rejeitado') DEFAULT 'ativo', -- MUDADO para 'ativo' padrão
    avaliacao_media DECIMAL(3,2) DEFAULT 0.00,
    total_avaliacoes INT DEFAULT 0,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE
);

-- Tabela de Consultas
CREATE TABLE Consulta (
    id_consulta INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_psicologo INT NOT NULL,
    data_consulta DATE NOT NULL,
    horario TIME NOT NULL,
    observacoes TEXT,
    status ENUM('agendada', 'confirmada', 'realizada', 'cancelada') DEFAULT 'agendada',
    data_agendamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente) ON DELETE CASCADE,
    FOREIGN KEY (id_psicologo) REFERENCES Psicologo(id_psicologo) ON DELETE CASCADE
);

-- Tabela de Relatos
CREATE TABLE Relato (
    id_relato INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    conteudo TEXT NOT NULL,
    data_postagem TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    curtidas INT DEFAULT 0,
    status ENUM('pendente', 'ativo', 'rejeitado') DEFAULT 'ativo',
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente) ON DELETE CASCADE
);

-- Tabela de Chat
CREATE TABLE Chat (
    id_mensagem INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_psicologo INT NOT NULL,
    id_remetente INT NOT NULL,
    mensagem TEXT NOT NULL,
    data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lida BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente) ON DELETE CASCADE,
    FOREIGN KEY (id_psicologo) REFERENCES Psicologo(id_psicologo) ON DELETE CASCADE
);

-- Tabela de Avaliações
CREATE TABLE Avaliacao (
    id_avaliacao INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_psicologo INT NOT NULL,
    nota INT NOT NULL CHECK (nota >= 1 AND nota <= 5),
    comentario TEXT,
    data_avaliacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente) ON DELETE CASCADE,
    FOREIGN KEY (id_psicologo) REFERENCES Psicologo(id_psicologo) ON DELETE CASCADE
);

-- Inserir dados iniciais
-- Senha para todos: Admin123 (hash: $2a$10$N9qo8uLOickgx2ZMRZoMye7GnwHZ1pY1pY1pY1pY1pY1pY1pY1pY)

-- Moderador
INSERT INTO Usuario (nome, email, senha, tipo, telefone) VALUES 
('Moderador Admin', 'moderador@psicohelp.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye7GnwHZ1pY1pY1pY1pY1pY1pY1pY1pY', 'moderador', '(11) 99999-9999');

-- Psicólogos
INSERT INTO Usuario (nome, email, senha, tipo, telefone) VALUES 
('Dra. Ana Silva', 'ana.silva@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye7GnwHZ1pY1pY1pY1pY1pY1pY1pY1pY', 'psicologo', '(11) 98888-8888'),
('Dr. Carlos Santos', 'carlos.santos@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye7GnwHZ1pY1pY1pY1pY1pY1pY1pY1pY', 'psicologo', '(11) 97777-7777'),
('Dra. Mariana Oliveira', 'mariana@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye7GnwHZ1pY1pY1pY1pY1pY1pY1pY1pY', 'psicologo', '(11) 96666-6666');

SET @ana_id = (SELECT id_usuario FROM Usuario WHERE email = 'ana.silva@email.com');
SET @carlos_id = (SELECT id_usuario FROM Usuario WHERE email = 'carlos.santos@email.com');
SET @mariana_id = (SELECT id_usuario FROM Usuario WHERE email = 'mariana@email.com');

INSERT INTO Psicologo (id_usuario, CRP, especialidade, formacao, abordagem, experiencia, descricao, status) VALUES
(@ana_id, '06/12345', 'Psicologia Clínica', 'Graduação em Psicologia - USP\nMestrado em Terapia Cognitiva', 'TCC', 8, 'Especialista em ansiedade e depressão. Atendo adolescentes e adultos.', 'ativo'),
(@carlos_id, '06/67890', 'Terapia Cognitivo-Comportamental', 'Graduação em Psicologia - UNESP\nEspecialização em TCC', 'TCC', 5, 'Foco em terapia para adultos com fobias e transtornos de ansiedade.', 'ativo'),
(@mariana_id, '06/54321', 'Psicologia Infantil', 'Graduação em Psicologia - PUC\nEspecialização em Psicologia Infantil', 'Ludoterapia', 10, 'Especialista em atendimento infantil e orientação parental.', 'ativo');

-- Clientes
INSERT INTO Usuario (nome, email, senha, tipo, telefone) VALUES 
('João da Silva', 'joao@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye7GnwHZ1pY1pY1pY1pY1pY1pY1pY1pY', 'cliente', '(11) 95555-5555'),
('Maria Oliveira', 'maria@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye7GnwHZ1pY1pY1pY1pY1pY1pY1pY1pY', 'cliente', '(11) 94444-4444');

SET @joao_id = (SELECT id_usuario FROM Usuario WHERE email = 'joao@email.com');
SET @maria_id = (SELECT id_usuario FROM Usuario WHERE email = 'maria@email.com');

INSERT INTO Cliente (id_usuario) VALUES (@joao_id), (@maria_id);

-- Relatos iniciais
INSERT INTO Relato (id_cliente, titulo, conteudo, curtidas, status) VALUES
(1, 'Minha jornada na terapia', 'Há 6 meses iniciei terapia e minha vida mudou completamente. Aprendi a lidar com minha ansiedade...', 15, 'ativo'),
(2, 'Superando a depressão', 'Queria compartilhar minha vitória sobre a depressão. Foi um caminho difícil, mas com ajuda profissional...', 23, 'ativo'),
(1, 'Dicas para quem está começando', 'Para quem está pensando em iniciar terapia: não desista na primeira sessão, dê tempo ao tempo...', 8, 'ativo');

-- Consultas de exemplo
INSERT INTO Consulta (id_cliente, id_psicologo, data_consulta, horario, status) VALUES
(1, 1, DATE_ADD(CURDATE(), INTERVAL 7 DAY), '14:00:00', 'agendada'),
(2, 2, DATE_ADD(CURDATE(), INTERVAL 3 DAY), '10:00:00', 'confirmada'),
(1, 3, DATE_SUB(CURDATE(), INTERVAL 15 DAY), '16:00:00', 'realizada');

-- Avaliações
INSERT INTO Avaliacao (id_cliente, id_psicologo, nota, comentario) VALUES
(1, 1, 5, 'Excelente profissional, muito atenciosa!'),
(2, 2, 4, 'Bom psicólogo, me ajudou bastante.'),
(1, 3, 5, 'Mariana é incrível com crianças!');

-- Atualizar avaliação média dos psicólogos
UPDATE Psicologo p SET 
    avaliacao_media = (SELECT AVG(nota) FROM Avaliacao WHERE id_psicologo = p.id_psicologo),
    total_avaliacoes = (SELECT COUNT(*) FROM Avaliacao WHERE id_psicologo = p.id_psicologo);

-- Verificar dados
SELECT '=== USUÁRIOS ===' as '';
SELECT * FROM Usuario;

SELECT '=== PSICÓLOGOS ===' as '';
SELECT p.*, u.nome, u.email FROM Psicologo p JOIN Usuario u ON p.id_usuario = u.id_usuario;

SELECT '=== CLIENTES ===' as '';
SELECT c.*, u.nome, u.email FROM Cliente c JOIN Usuario u ON c.id_usuario = u.id_usuario;

SELECT '=== RELATOS ===' as '';
SELECT r.*, u.nome FROM Relato r JOIN Cliente c ON r.id_cliente = c.id_cliente JOIN Usuario u ON c.id_usuario = u.id_usuario;

SELECT '=== CONSULTAS ===' as '';
SELECT con.*, 
       cli_u.nome as cliente_nome,
       psi_u.nome as psicologo_nome
FROM Consulta con
JOIN Cliente cli ON con.id_cliente = cli.id_cliente
JOIN Usuario cli_u ON cli.id_usuario = cli_u.id_usuario
JOIN Psicologo psi ON con.id_psicologo = psi.id_psicologo
JOIN Usuario psi_u ON psi.id_usuario = psi_u.id_usuario;

SELECT '=== AVALIAÇÕES ===' as '';
SELECT a.*, 
       cli_u.nome as cliente_nome,
       psi_u.nome as psicologo_nome
FROM Avaliacao a
JOIN Cliente cli ON a.id_cliente = cli.id_cliente
JOIN Usuario cli_u ON cli.id_usuario = cli_u.id_usuario
JOIN Psicologo psi ON a.id_psicologo = psi.id_psicologo
JOIN Usuario psi_u ON psi.id_usuario = psi_u.id_usuario;