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

-- --------------------------------------------------------

--
-- Estrutura para tabela `cliente`
--

CREATE TABLE `cliente` (
  `id_cliente` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `data_nascimento` date DEFAULT NULL,
  `genero` enum('M','F','Outro') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `cliente`
--

INSERT INTO `cliente` (`id_cliente`, `id_usuario`, `data_nascimento`, `genero`) VALUES
(1, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Estrutura para tabela `consulta`
--

CREATE TABLE `consulta` (
  `id_consulta` int(11) NOT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `id_psicologo` int(11) DEFAULT NULL,
  `data_consulta` date DEFAULT NULL,
  `horario` time DEFAULT NULL,
  `tipo` enum('presencial','online') DEFAULT NULL,
  `observacoes` text DEFAULT NULL,
  `status` enum('agendada','confirmada','realizada','cancelada') DEFAULT 'agendada',
  `data_criacao` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `consulta`
--

INSERT INTO `consulta` (`id_consulta`, `id_cliente`, `id_psicologo`, `data_consulta`, `horario`, `tipo`, `observacoes`, `status`, `data_criacao`) VALUES
(1, 1, 3, '2025-12-06', '15:00:00', 'online', 'welwehweiw4 ', 'agendada', '2025-11-23 19:04:22'),
(2, 1, 2, '2025-11-29', '10:00:00', 'online', 'dghrrtr', 'agendada', '2025-11-23 20:07:55');

-- --------------------------------------------------------

--
-- Estrutura para tabela `curtida`
--

CREATE TABLE `curtida` (
  `id_curtida` int(11) NOT NULL,
  `id_relato` int(11) DEFAULT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `data_curtida` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `curtida`
--

INSERT INTO `curtida` (`id_curtida`, `id_relato`, `id_usuario`, `data_curtida`) VALUES
(17, 3, 1, '2025-11-23 17:12:10');

-- --------------------------------------------------------

--
-- Estrutura para tabela `mensagem`
--

CREATE TABLE `mensagem` (
  `id_mensagem` int(11) NOT NULL,
  `id_remetente` int(11) DEFAULT NULL,
  `id_destinatario` int(11) DEFAULT NULL,
  `mensagem` text NOT NULL,
  `data_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  `lida` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `psicologo`
--

CREATE TABLE `psicologo` (
  `id_psicologo` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `CRP` varchar(20) DEFAULT NULL,
  `especialidade` varchar(100) DEFAULT NULL,
  `disponibilidade` text DEFAULT NULL,
  `telefone` varchar(20) DEFAULT NULL,
  `status` enum('pendente','aprovado','rejeitado') DEFAULT 'pendente',
  `formacao` varchar(200) DEFAULT NULL,
  `abordagem` varchar(100) DEFAULT NULL,
  `experiencia` int(11) DEFAULT NULL,
  `descricao` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `psicologo`
--

INSERT INTO `psicologo` (`id_psicologo`, `id_usuario`, `CRP`, `especialidade`, `disponibilidade`, `telefone`, `status`, `formacao`, `abordagem`, `experiencia`, `descricao`) VALUES
(1, 2, '01/000', 'psicoooo', NULL, '33444444444', 'pendente', NULL, NULL, NULL, NULL),
(2, 3, '56644', 'clicinia', NULL, NULL, '', 'usp', 'TCC', 6, 'tsehesthe'),
(3, 4, '56644', 'clicinia', NULL, NULL, '', 'usp', 'TCC', 6, 'erye');

-- --------------------------------------------------------

--
-- Estrutura para tabela `relato`
--

CREATE TABLE `relato` (
  `id_relato` int(11) NOT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `titulo` varchar(100) NOT NULL,
  `conteudo` text NOT NULL,
  `data_postagem` timestamp NOT NULL DEFAULT current_timestamp(),
  `curtidas` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `relato`
--

INSERT INTO `relato` (`id_relato`, `id_cliente`, `titulo`, `conteudo`, `data_postagem`, `curtidas`) VALUES
(1, 1, 'aerhaerh', 'reerhererh', '2025-11-22 14:19:26', 0),
(2, 1, 'hahaha', 'hahahah', '2025-11-23 07:26:10', 0),
(3, 1, 'rg', 'rggrgr', '2025-11-23 17:12:07', 1);

-- --------------------------------------------------------

--
-- Estrutura para tabela `sessao`
--

CREATE TABLE `sessao` (
  `id_sessao` int(11) NOT NULL,
  `id_psicologo` int(11) DEFAULT NULL,
  `id_cliente` int(11) DEFAULT NULL,
  `data` date NOT NULL,
  `hora` time NOT NULL,
  `status` enum('agendada','confirmada','realizada','cancelada') DEFAULT 'agendada',
  `link_video` varchar(255) DEFAULT NULL,
  `observacao` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `nome` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `tipo` enum('cliente','psicologo') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `telefone` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `nome`, `email`, `senha`, `tipo`, `created_at`, `telefone`) VALUES
(1, 'joao', 'joao@gmail', '$2b$10$avsi5z/L2g00eWv5JpRCiuxdHYzKLsVIqRcD8Rei9WZphgnmHjRN2', 'cliente', '2025-11-21 20:32:42', NULL),
(2, 'Dr. João Silva', 'silva@gmail', '$2b$10$H4tIrN8.7pbCigtQkzJVjuyF0SmG/kLWu0htIwnKYim6qpIOFQABq', 'psicologo', '2025-11-23 05:43:50', NULL),
(3, 'dhawgwr', 'rgdherh@gmail', '$2b$10$wNCzbYipQ/mYhGdD6SaKB.NtoxLw8p8ZC8h9HvFpEH41yA1e3/R46', 'psicologo', '2025-11-23 07:43:28', '45355355'),
(4, 'trrt', 'hguer@gmail', '$2b$10$Obg4thjNtQUx71FX0wqsWOCTlPxSJAEMpgV3Vgq9YDhvKdzcK6IU2', 'psicologo', '2025-11-23 14:09:19', '45355355');

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`id_cliente`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Índices de tabela `consulta`
--
ALTER TABLE `consulta`
  ADD PRIMARY KEY (`id_consulta`),
  ADD KEY `id_cliente` (`id_cliente`),
  ADD KEY `id_psicologo` (`id_psicologo`);

--
-- Índices de tabela `curtida`
--
ALTER TABLE `curtida`
  ADD PRIMARY KEY (`id_curtida`),
  ADD KEY `id_relato` (`id_relato`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Índices de tabela `mensagem`
--
ALTER TABLE `mensagem`
  ADD PRIMARY KEY (`id_mensagem`),
  ADD KEY `id_remetente` (`id_remetente`),
  ADD KEY `id_destinatario` (`id_destinatario`);

--
-- Índices de tabela `psicologo`
--
ALTER TABLE `psicologo`
  ADD PRIMARY KEY (`id_psicologo`),
  ADD KEY `id_usuario` (`id_usuario`);

--
-- Índices de tabela `relato`
--
ALTER TABLE `relato`
  ADD PRIMARY KEY (`id_relato`),
  ADD KEY `id_cliente` (`id_cliente`);

--
-- Índices de tabela `sessao`
--
ALTER TABLE `sessao`
  ADD PRIMARY KEY (`id_sessao`),
  ADD KEY `id_psicologo` (`id_psicologo`),
  ADD KEY `id_cliente` (`id_cliente`);

--
-- Índices de tabela `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `cliente`
--
ALTER TABLE `cliente`
  MODIFY `id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `consulta`
--
ALTER TABLE `consulta`
  MODIFY `id_consulta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `curtida`
--
ALTER TABLE `curtida`
  MODIFY `id_curtida` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de tabela `mensagem`
--
ALTER TABLE `mensagem`
  MODIFY `id_mensagem` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `psicologo`
--
ALTER TABLE `psicologo`
  MODIFY `id_psicologo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `relato`
--
ALTER TABLE `relato`
  MODIFY `id_relato` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de tabela `sessao`
--
ALTER TABLE `sessao`
  MODIFY `id_sessao` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `cliente_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Restrições para tabelas `consulta`
--
ALTER TABLE `consulta`
  ADD CONSTRAINT `consulta_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `consulta_ibfk_2` FOREIGN KEY (`id_psicologo`) REFERENCES `psicologo` (`id_psicologo`);

--
-- Restrições para tabelas `curtida`
--
ALTER TABLE `curtida`
  ADD CONSTRAINT `curtida_ibfk_1` FOREIGN KEY (`id_relato`) REFERENCES `relato` (`id_relato`),
  ADD CONSTRAINT `curtida_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Restrições para tabelas `mensagem`
--
ALTER TABLE `mensagem`
  ADD CONSTRAINT `mensagem_ibfk_1` FOREIGN KEY (`id_remetente`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `mensagem_ibfk_2` FOREIGN KEY (`id_destinatario`) REFERENCES `usuario` (`id_usuario`);

--
-- Restrições para tabelas `psicologo`
--
ALTER TABLE `psicologo`
  ADD CONSTRAINT `psicologo_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Restrições para tabelas `relato`
--
ALTER TABLE `relato`
  ADD CONSTRAINT `relato_ibfk_1` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`);

--
-- Restrições para tabelas `sessao`
--
ALTER TABLE `sessao`
  ADD CONSTRAINT `sessao_ibfk_1` FOREIGN KEY (`id_psicologo`) REFERENCES `psicologo` (`id_psicologo`),
  ADD CONSTRAINT `sessao_ibfk_2` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
