-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 23/11/2025 às 21:39
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `psicohelp`
--
CREATE DATABASE IF NOT EXISTS `psicohelp` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `psicohelp`;

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuario`
--

DROP TABLE IF EXISTS `usuario`;
CREATE TABLE IF NOT EXISTS `usuario` (
  `id_usuario` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `tipo` enum('cliente','psicologo') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `telefone` varchar(20) DEFAULT NULL,
  `ativo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `usuario`
--

INSERT IGNORE INTO `usuario` (`id_usuario`, `nome`, `email`, `senha`, `tipo`, `created_at`, `telefone`, `ativo`) VALUES
(1, 'joao', 'joao@gmail', '$2b$10$avsi5z/L2g00eWv5JpRCiuxdHYzKLsVIqRcD8Rei9WZphgnmHjRN2', 'cliente', '2025-11-21 20:32:42', NULL, 1),
(2, 'Dr. João Silva', 'silva@gmail', '$2b$10$H4tIrN8.7pbCigtQkzJVjuyF0SmG/kLWu0htIwnKYim6qpIOFQABq', 'psicologo', '2025-11-23 05:43:50', NULL, 1),
(3, 'dhawgwr', 'rgdherh@gmail', '$2b$10$wNCzbYipQ/mYhGdD6SaKB.NtoxLw8p8ZC8h9HvFpEH41yA1e3/R46', 'psicologo', '2025-11-23 07:43:28', '45355355', 1),
(4, 'trrt', 'hguer@gmail', '$2b$10$Obg4thjNtQUx71FX0wqsWOCTlPxSJAEMpgV3Vgq9YDhvKdzcK6IU2', 'psicologo', '2025-11-23 14:09:19', '45355355', 1);

-- --------------------------------------------------------

--
-- Estrutura para tabela `cliente`
--

DROP TABLE IF EXISTS `cliente`;
CREATE TABLE IF NOT EXISTS `cliente` (
  `id_cliente` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `data_nascimento` date DEFAULT NULL,
  `genero` enum('M','F','Outro','Prefiro não informar') DEFAULT 'Prefiro não informar',
  `telefone_contato` varchar(20) DEFAULT NULL,
  `endereco` text DEFAULT NULL,
  `cidade` varchar(100) DEFAULT NULL,
  `estado` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `cliente_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `cliente`
--

INSERT IGNORE INTO `cliente` (`id_cliente`, `id_usuario`, `data_nascimento`, `genero`, `telefone_contato`, `endereco`, `cidade`, `estado`) VALUES
(1, 1, NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estrutura para tabela `psicologo`
--

DROP TABLE IF EXISTS `psicologo`;
CREATE TABLE IF NOT EXISTS `psicologo` (
  `id_psicologo` int(11) NOT NULL AUTO_INCREMENT,
  `id_usuario` int(11) NOT NULL,
  `CRP` varchar(20) NOT NULL,
  `especialidade` varchar(100) DEFAULT NULL,
  `disponibilidade` text DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `status` enum('pendente','aprovado','rejeitado') DEFAULT 'pendente',
  `formacao` varchar(200) DEFAULT NULL,
  `abordagem` varchar(100) DEFAULT NULL,
  `experiencia` int(11) DEFAULT NULL,
  `descricao` text DEFAULT NULL,
  `valor_consulta` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_psicologo`),
  UNIQUE KEY `CRP` (`CRP`),
  UNIQUE KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `psicologo_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `psicologo`
--

INSERT IGNORE INTO `psicologo` (`id_psicologo`, `id_usuario`, `CRP`, `especialidade`, `disponibilidade`, `telefone`, `status`, `formacao`, `abordagem`, `experiencia`, `descricao`, `valor_consulta`) VALUES
(1, 2, '01/000', 'psicoooo', NULL, '33444444444', 'pendente', NULL, NULL, NULL, NULL, NULL),
(2, 3, '56644', 'clicinia', NULL, NULL, 'pendente', 'usp', 'TCC', 6, 'tsehesthe', NULL),
(3, 4, '56644-2', 'clicinia', NULL, NULL, 'pendente', 'usp', 'TCC', 6, 'erye', NULL);

-- --------------------------------------------------------

--
-- Estrutura para tabela `relato`
--

DROP TABLE IF EXISTS `relato`;
CREATE TABLE IF NOT EXISTS `relato` (
  `id_relato` int(11) NOT NULL AUTO_INCREMENT,
  `id_cliente` int(11) NOT NULL,
  `titulo` varchar(100) NOT NULL,
  `conteudo` text NOT NULL,
  `data_postagem` timestamp NOT NULL DEFAULT current_timestamp(),
  `curtidas` int(11) DEFAULT 0,
  `anonimo` tinyint(1) DEFAULT 0,
  `status` enum('ativo','inativo','removido') DEFAULT 'ativo',
  PRIMARY KEY (`id_relato`),
  KEY `id_cliente` (`id_cliente`),
  CONSTRAINT `relato_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `relato`
--

INSERT IGNORE INTO `relato` (`id_relato`, `id_cliente`, `titulo`, `conteudo`, `data_postagem`, `curtidas`, `anonimo`, `status`) VALUES
(1, 1, 'aerhaerh', 'reerhererh', '2025-11-22 14:19:26', 0, 0, 'ativo'),
(2, 1, 'hahaha', 'hahahah', '2025-11-23 07:26:10', 0, 0, 'ativo'),
(3, 1, 'rg', 'rggrgr', '2025-11-23 17:12:07', 1, 0, 'ativo');

-- --------------------------------------------------------

--
-- Estrutura para tabela `curtida`
--

DROP TABLE IF EXISTS `curtida`;
CREATE TABLE IF NOT EXISTS `curtida` (
  `id_curtida` int(11) NOT NULL AUTO_INCREMENT,
  `id_relato` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `data_curtida` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_curtida`),
  UNIQUE KEY `unique_curtida` (`id_relato`,`id_usuario`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `curtida_ibfk_1` FOREIGN KEY (`id_relato`) REFERENCES `relato` (`id_relato`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `curtida_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `curtida`
--

INSERT IGNORE INTO `curtida` (`id_curtida`, `id_relato`, `id_usuario`, `data_curtida`) VALUES
(17, 3, 1, '2025-11-23 17:12:10');

-- --------------------------------------------------------

--
-- Estrutura para tabela `consulta`
--

DROP TABLE IF EXISTS `consulta`;
CREATE TABLE IF NOT EXISTS `consulta` (
  `id_consulta` int(11) NOT NULL AUTO_INCREMENT,
  `id_cliente` int(11) NOT NULL,
  `id_psicologo` int(11) NOT NULL,
  `data_consulta` date NOT NULL,
  `horario` time NOT NULL,
  `duracao` int(11) DEFAULT 50,
  `tipo` enum('presencial','online') DEFAULT 'online',
  `observacoes` text DEFAULT NULL,
  `status` enum('agendada','confirmada','realizada','cancelada','remarcada') DEFAULT 'agendada',
  `valor_consulta` decimal(10,2) DEFAULT NULL,
  `link_video` varchar(255) DEFAULT NULL,
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp(),
  `data_atualizacao` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_consulta`),
  KEY `id_cliente` (`id_cliente`),
  KEY `id_psicologo` (`id_psicologo`),
  CONSTRAINT `consulta_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `consulta_ibfk_2` FOREIGN KEY (`id_psicologo`) REFERENCES `psicologo` (`id_psicologo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `consulta`
--

INSERT IGNORE INTO `consulta` (`id_consulta`, `id_cliente`, `id_psicologo`, `data_consulta`, `horario`, `duracao`, `tipo`, `observacoes`, `status`, `valor_consulta`, `link_video`) VALUES
(1, 1, 3, '2025-12-06', '15:00:00', 50, 'online', 'welwehweiw4 ', 'agendada', NULL, NULL),
(2, 1, 2, '2025-11-29', '10:00:00', 50, 'online', 'dghrrtr', 'agendada', NULL, NULL);

-- --------------------------------------------------------

--
-- Estrutura para tabela `sessao`
--

DROP TABLE IF EXISTS `sessao`;
CREATE TABLE IF NOT EXISTS `sessao` (
  `id_sessao` int(11) NOT NULL AUTO_INCREMENT,
  `id_psicologo` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `data` date NOT NULL,
  `hora` time NOT NULL,
  `duracao` int(11) DEFAULT 50,
  `status` enum('agendada','confirmada','realizada','cancelada','remarcada') DEFAULT 'agendada',
  `link_video` varchar(255) DEFAULT NULL,
  `observacao` text DEFAULT NULL,
  `valor` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id_sessao`),
  KEY `id_psicologo` (`id_psicologo`),
  KEY `id_cliente` (`id_cliente`),
  CONSTRAINT `sessao_ibfk_1` FOREIGN KEY (`id_psicologo`) REFERENCES `psicologo` (`id_psicologo`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sessao_ibfk_2` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `mensagem`
--

DROP TABLE IF EXISTS `mensagem`;
CREATE TABLE IF NOT EXISTS `mensagem` (
  `id_mensagem` int(11) NOT NULL AUTO_INCREMENT,
  `id_remetente` int(11) NOT NULL,
  `id_destinatario` int(11) NOT NULL,
  `mensagem` text NOT NULL,
  `data_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  `lida` tinyint(1) DEFAULT 0,
  `tipo` enum('texto','sistema','notificacao') DEFAULT 'texto',
  PRIMARY KEY (`id_mensagem`),
  KEY `id_remetente` (`id_remetente`),
  KEY `id_destinatario` (`id_destinatario`),
  CONSTRAINT `mensagem_ibfk_1` FOREIGN KEY (`id_remetente`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `mensagem_ibfk_2` FOREIGN KEY (`id_destinatario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Índices para tabelas despejadas
--

--
-- Restrições para tabelas despejadas
--

DELIMITER $$
--
-- Eventos
--
CREATE EVENT IF NOT EXISTS `limpar_sessoes_antigas` ON SCHEDULE EVERY 1 DAY STARTS '2025-11-24 00:00:00' ON COMPLETION PRESERVE ENABLE DO BEGIN
    DELETE FROM sessao WHERE data < CURDATE() - INTERVAL 30 DAY AND status = 'realizada';
END$$

DELIMITER ;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;