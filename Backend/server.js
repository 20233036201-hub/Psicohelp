// server.js - VERSÃO CORRIGIDA
const express = require('express');
const cors = require('cors');
const path = require('path');
const db = require('./config/db');
const bcrypt = require('bcryptjs');
const session = require('express-session');
const cookieParser = require('cookie-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// ==================== CONFIGURAÇÃO ====================
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// CORS
app.use(cors({
    origin: ['http://localhost:3000', 'http://localhost:5500', 'http://127.0.0.1:5500'],
    credentials: true
}));

// SESSÃO
app.use(session({
    secret: process.env.SESSION_SECRET || 'psicohelp-secret-2025',
    resave: false,
    saveUninitialized: false,
    cookie: {
        maxAge: 24 * 60 * 60 * 1000, // 24 horas
        httpOnly: true,
        secure: false
    }
}));

// Middleware para log
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

// Middleware de autenticação para APIs
const requireAuth = (req, res, next) => {
    if (!req.session.userId) {
        return res.status(401).json({ error: 'Não autenticado' });
    }
    next();
};

// Middleware para verificar autenticação em páginas HTML
const checkAuthAndRedirect = (req, res, next) => {
    if (!req.session.userId) {
        return res.redirect('/');
    }
    next();
};

// ==================== SERVIR ARQUIVOS ESTÁTICOS ====================
app.use(express.static(path.join(__dirname, '..', 'frontend')));

// ==================== ROTAS DE PÁGINAS ====================

// Página inicial (login) - SEM autenticação necessária
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'frontend', 'login', 'index.html'));
});

// Home - COM autenticação
app.get('/home', checkAuthAndRedirect, (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'frontend', 'home', 'index.html'));
});

// Perfil - COM autenticação
app.get('/perfil', checkAuthAndRedirect, (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'frontend', 'perfil', 'index.html'));
});

// Agendar - COM verificação de tipo de usuário
app.get('/agendar', checkAuthAndRedirect, async (req, res) => {
    try {
        const [user] = await db.promise().query(
            'SELECT tipo FROM Usuario WHERE id_usuario = ?',
            [req.session.userId]
        );
        
        // Psicólogo não pode agendar consultas
        if (user[0].tipo === 'psicologo') {
            return res.redirect('/home');
        }
        
        res.sendFile(path.join(__dirname, '..', 'frontend', 'agendar', 'index.html'));
    } catch (error) {
        console.error('Erro ao verificar tipo de usuário:', error);
        res.redirect('/home');
    }
});

// Confirmar agendamento - COM verificação de tipo de usuário
app.get('/confirmar_agendamento', checkAuthAndRedirect, async (req, res) => {
    try {
        const [user] = await db.promise().query(
            'SELECT tipo FROM Usuario WHERE id_usuario = ?',
            [req.session.userId]
        );
        
        // Psicólogo não pode agendar consultas
        if (user[0].tipo === 'psicologo') {
            return res.redirect('/home');
        }
        
        res.sendFile(path.join(__dirname, '..', 'frontend', 'confirmar_agendamento', 'index.html'));
    } catch (error) {
        console.error('Erro ao verificar tipo de usuário:', error);
        res.redirect('/home');
    }
});

// Minhas consultas - COM redirecionamento baseado no tipo
app.get('/minhas_consultas', checkAuthAndRedirect, async (req, res) => {
    try {
        const [user] = await db.promise().query(
            'SELECT tipo FROM Usuario WHERE id_usuario = ?',
            [req.session.userId]
        );
        
        // Se for psicólogo, redirecionar para versão psicólogo
        if (user[0].tipo === 'psicologo') {
            return res.redirect('/psicologo/consultas');
        }
        
        res.sendFile(path.join(__dirname, '..', 'frontend', 'minhas_consultas', 'index.html'));
    } catch (error) {
        console.error('Erro ao verificar tipo de usuário:', error);
        res.redirect('/home');
    }
});

// Página de consultas do psicólogo
app.get('/psicologo/consultas', checkAuthAndRedirect, async (req, res) => {
    try {
        const [user] = await db.promise().query(
            'SELECT tipo FROM Usuario WHERE id_usuario = ?',
            [req.session.userId]
        );
        
        // Se não for psicólogo, redirecionar para consultas normais
        if (user[0].tipo !== 'psicologo') {
            return res.redirect('/minhas_consultas');
        }
        
        res.sendFile(path.join(__dirname, '..', 'frontend', 'psicologo_consultas', 'index.html'));
    } catch (error) {
        console.error('Erro ao verificar tipo de usuário:', error);
        res.redirect('/home');
    }
});

// Outras páginas
app.get('/chat', checkAuthAndRedirect, (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'frontend', 'chat', 'index.html'));
});

app.get('/cadastro/cliente', (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'frontend', 'cadastro_cliente', 'index.html'));
});

app.get('/cadastro/psicologo', (req, res) => {
    res.sendFile(path.join(__dirname, '..', 'frontend', 'cadastro_psicologo', 'index.html'));
});

app.get('/moderador', checkAuthAndRedirect, async (req, res) => {
    try {
        const [user] = await db.promise().query(
            'SELECT tipo FROM Usuario WHERE id_usuario = ?',
            [req.session.userId]
        );
        
        if (user[0].tipo !== 'moderador') {
            return res.redirect('/home');
        }
        
        res.sendFile(path.join(__dirname, '..', 'frontend', 'moderador', 'index.html'));
    } catch (error) {
        console.error('Erro ao verificar tipo de usuário:', error);
        res.redirect('/home');
    }
});

// ==================== ROTAS API ====================

// 1. CADASTRO
app.post('/api/cadastro', async (req, res) => {
    try {
        const { nome, email, senha, tipo, telefone, crp, especialidade, formacao, abordagem, experiencia, sobre } = req.body;

        if (!nome || !email || !senha || !tipo) {
            return res.status(400).json({ error: 'Preencha todos os campos obrigatórios' });
        }

        // Verificar email
        const [existingUser] = await db.promise().query('SELECT id_usuario FROM Usuario WHERE email = ?', [email]);
        if (existingUser.length > 0) {
            return res.status(400).json({ error: 'Email já cadastrado' });
        }

        // Hash da senha
        const hashedPassword = await bcrypt.hash(senha, 10);

        // Inserir usuário
        const [userResult] = await db.promise().query(
            'INSERT INTO Usuario (nome, email, senha, tipo, telefone) VALUES (?, ?, ?, ?, ?)',
            [nome, email, hashedPassword, tipo, telefone || null]
        );

        const userId = userResult.insertId;

        // Inserir dados específicos
        if (tipo === 'psicologo') {
            await db.promise().query(
                `INSERT INTO Psicologo (id_usuario, CRP, especialidade, formacao, abordagem, experiencia, descricao, status) 
                VALUES (?, ?, ?, ?, ?, ?, ?, 'ativo')`,  
                [userId, crp || '', especialidade || '', formacao || '', abordagem || '', experiencia || 0, sobre || '']
            );
            console.log(`✅ Psicólogo cadastrado: ${nome}`);
        } else {
            await db.promise().query(
                'INSERT INTO Cliente (id_usuario) VALUES (?)',
                [userId]
            );
            console.log(`✅ Cliente cadastrado: ${nome}`);
        }

        res.json({ 
            success: true, 
            message: `${tipo === 'psicologo' ? 'Psicólogo' : 'Cliente'} cadastrado com sucesso!`,
            userId 
        });

    } catch (error) {
        console.error('❌ Erro no cadastro:', error);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

// 2. LOGIN
app.post('/api/login', async (req, res) => {
    try {
        const { email, senha } = req.body;

        const [users] = await db.promise().query(
            'SELECT * FROM Usuario WHERE email = ?',
            [email]
        );

        if (users.length === 0) {
            return res.status(401).json({ error: 'Email ou senha incorretos' });
        }

        const user = users[0];
        const validPassword = await bcrypt.compare(senha, user.senha);

        if (!validPassword) {
            return res.status(401).json({ error: 'Email ou senha incorretos' });
        }

        // Criar sessão
        req.session.userId = user.id_usuario;
        req.session.userType = user.tipo;
        req.session.userName = user.nome;
        req.session.userEmail = user.email;

        console.log(`✅ Login: ${user.nome} (${user.tipo})`);

        res.json({
            success: true,
            message: 'Login realizado com sucesso!',
            user: {
                id: user.id_usuario,
                nome: user.nome,
                email: user.email,
                tipo: user.tipo
            }
        });

    } catch (error) {
        console.error('❌ Erro no login:', error);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

// 3. LOGOUT
app.post('/api/logout', (req, res) => {
    req.session.destroy();
    res.json({ success: true, message: 'Logout realizado' });
});

// 4. USUÁRIO ATUAL
app.get('/api/usuario/atual', requireAuth, async (req, res) => {
    try {
        const [users] = await db.promise().query(`
            SELECT 
                u.*,
                p.CRP,
                p.especialidade,
                p.formacao,
                p.abordagem,
                p.experiencia,
                p.descricao,
                p.status as status_psicologo,
                p.avaliacao_media,
                p.total_avaliacoes,
                c.id_cliente
            FROM Usuario u
            LEFT JOIN Psicologo p ON u.id_usuario = p.id_usuario
            LEFT JOIN Cliente c ON u.id_usuario = c.id_usuario
            WHERE u.id_usuario = ?
        `, [req.session.userId]);

        if (users.length === 0) {
            return res.status(404).json({ error: 'Usuário não encontrado' });
        }
        
        res.json(users[0]);
    } catch (error) {
        console.error('❌ Erro ao buscar usuário:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// 5. LISTAR PSICÓLOGOS (APENAS ATIVOS)
app.get('/api/psicologos', async (req, res) => {
    try {
        console.log('📋 Buscando psicólogos...');
        
        const [psicologos] = await db.promise().query(`
            SELECT 
                p.id_psicologo,
                p.id_usuario,
                p.CRP,
                p.especialidade,
                p.formacao,
                p.abordagem,
                p.experiencia,
                p.descricao,
                p.status,
                p.avaliacao_media,
                p.total_avaliacoes,
                u.nome,
                u.email,
                u.telefone
            FROM Psicologo p
            INNER JOIN Usuario u ON p.id_usuario = u.id_usuario
            WHERE p.status = 'ativo'
            ORDER BY u.nome ASC
        `);

        console.log(`✅ Encontrados ${psicologos.length} psicólogos`);

        if (psicologos.length === 0) {
            console.log('⚠️ Nenhum psicólogo ativo encontrado');
            return res.json([]);
        }

        res.json(psicologos);
    } catch (error) {
        console.error('❌ Erro ao listar psicólogos:', error);
        console.error('Detalhes do erro:', error.message);
        res.status(500).json({ error: 'Erro interno do servidor: ' + error.message });
    }
});

// 6. AGENDAR CONSULTA
app.post('/api/agendamentos', requireAuth, async (req, res) => {
    try {
        const { id_psicologo, data, horario, observacoes } = req.body;
        const userId = req.session.userId;

        console.log(`📅 Agendando: Usuário ${userId} -> Psicólogo ${id_psicologo}`);

        // Buscar ID do cliente
        const [cliente] = await db.promise().query(
            'SELECT id_cliente FROM Cliente WHERE id_usuario = ?',
            [userId]
        );

        if (cliente.length === 0) {
            // Criar registro automaticamente se não existir
            const [clienteResult] = await db.promise().query(
                'INSERT INTO Cliente (id_usuario) VALUES (?)',
                [userId]
            );
            var id_cliente = clienteResult.insertId;
        } else {
            var id_cliente = cliente[0].id_cliente;
        }

        // Verificar se psicólogo existe
        const [psicologo] = await db.promise().query(
            `SELECT p.id_psicologo, p.status, u.nome 
             FROM Psicologo p 
             JOIN Usuario u ON p.id_usuario = u.id_usuario 
             WHERE p.id_psicologo = ?`,
            [id_psicologo]
        );

        if (psicologo.length === 0) {
            return res.status(404).json({ error: 'Psicólogo não encontrado' });
        }

        // Verificar conflito de horário
        const [consultaExistente] = await db.promise().query(
            `SELECT id_consulta FROM Consulta 
             WHERE id_psicologo = ? 
             AND data_consulta = ? 
             AND horario = ? 
             AND status != 'cancelada'`,
            [id_psicologo, data, horario]
        );

        if (consultaExistente.length > 0) {
            return res.status(400).json({ error: 'Este horário já está ocupado' });
        }

        // Inserir consulta
        const [result] = await db.promise().query(
            `INSERT INTO Consulta 
             (id_cliente, id_psicologo, data_consulta, horario, observacoes, status) 
             VALUES (?, ?, ?, ?, ?, 'agendada')`,
            [id_cliente, id_psicologo, data, horario, observacoes || '']
        );

        console.log(`✅ Consulta agendada! ID: ${result.insertId}`);
        
        res.json({
            success: true,
            message: 'Consulta agendada com sucesso!',
            id_consulta: result.insertId,
            nome_psicologo: psicologo[0].nome
        });

    } catch (error) {
        console.error('❌ Erro no agendamento:', error);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

// 7. MINHAS CONSULTAS (CLIENTE)
app.get('/api/minhas_consultas', requireAuth, async (req, res) => {
    try {
        const userId = req.session.userId;

        // Verificar tipo de usuário
        const [user] = await db.promise().query(
            'SELECT tipo FROM Usuario WHERE id_usuario = ?',
            [userId]
        );

        if (user.length === 0 || user[0].tipo !== 'cliente') {
            return res.status(403).json({ error: 'Apenas clientes podem acessar esta página' });
        }

        // Buscar id do cliente
        const [cliente] = await db.promise().query(
            'SELECT id_cliente FROM Cliente WHERE id_usuario = ?',
            [userId]
        );

        if (cliente.length === 0) {
            return res.json([]);
        }

        const id_cliente = cliente[0].id_cliente;

        // Buscar consultas deste cliente
        const [consultas] = await db.promise().query(`
            SELECT 
                c.id_consulta,
                c.data_consulta,
                c.horario,
                c.observacoes,
                c.status,
                u.nome AS nome_psicologo,
                p.especialidade,
                p.CRP
            FROM Consulta c
            INNER JOIN Psicologo p ON c.id_psicologo = p.id_psicologo
            INNER JOIN Usuario u ON p.id_usuario = u.id_usuario
            WHERE c.id_cliente = ?
            ORDER BY c.data_consulta DESC, c.horario DESC
        `, [id_cliente]);

        res.json(consultas);
    } catch (error) {
        console.error('❌ Erro ao buscar consultas:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// 8. CONSULTAS DO PSICÓLOGO
app.get('/api/psicologo/minhas_consultas', requireAuth, async (req, res) => {
    try {
        const userId = req.session.userId;

        // Verificar se é psicólogo
        const [user] = await db.promise().query(
            'SELECT tipo FROM Usuario WHERE id_usuario = ?',
            [userId]
        );

        if (user.length === 0 || user[0].tipo !== 'psicologo') {
            return res.status(403).json({ error: 'Apenas psicólogos podem acessar esta página' });
        }

        // Buscar id do psicólogo
        const [psicologo] = await db.promise().query(
            'SELECT id_psicologo FROM Psicologo WHERE id_usuario = ?',
            [userId]
        );

        if (psicologo.length === 0) {
            return res.json([]);
        }

        const id_psicologo = psicologo[0].id_psicologo;

        // Buscar consultas deste psicólogo
        const [consultas] = await db.promise().query(`
            SELECT 
                c.id_consulta,
                c.data_consulta,
                c.horario,
                c.observacoes,
                c.status,
                c.data_agendamento,
                u.nome AS nome_cliente,
                u.email,
                u.telefone
            FROM Consulta c
            INNER JOIN Cliente cli ON c.id_cliente = cli.id_cliente
            INNER JOIN Usuario u ON cli.id_usuario = u.id_usuario
            WHERE c.id_psicologo = ?
            ORDER BY c.data_consulta DESC, c.horario DESC
        `, [id_psicologo]);

        res.json(consultas);

    } catch (error) {
        console.error('❌ Erro ao buscar consultas do psicólogo:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// 9. FEED DE POSTS
app.get('/api/feed', async (req, res) => {
    try {
        const [posts] = await db.promise().query(`
            SELECT 
                r.id_relato,
                r.titulo,
                r.conteudo,
                r.data_postagem,
                r.curtidas,
                u.nome AS nome_cliente
            FROM Relato r
            INNER JOIN Cliente c ON r.id_cliente = c.id_cliente
            INNER JOIN Usuario u ON c.id_usuario = u.id_usuario
            WHERE r.status = 'ativo'
            ORDER BY r.data_postagem DESC
            LIMIT 20
        `);

        res.json(posts);
    } catch (error) {
        console.error('❌ Erro ao buscar feed:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// 10. CRIAR POST
app.post('/api/feed/post', requireAuth, async (req, res) => {
    try {
        const { titulo, conteudo } = req.body;
        const userId = req.session.userId;

        // Buscar id do cliente
        const [cliente] = await db.promise().query(
            'SELECT id_cliente FROM Cliente WHERE id_usuario = ?',
            [userId]
        );

        if (cliente.length === 0) {
            return res.status(403).json({ error: 'Apenas clientes podem criar posts' });
        }

        const id_cliente = cliente[0].id_cliente;

        // Validar
        if (!titulo || titulo.trim().length === 0) {
            return res.status(400).json({ error: 'Título é obrigatório' });
        }

        if (!conteudo || conteudo.trim().length === 0) {
            return res.status(400).json({ error: 'Conteúdo é obrigatório' });
        }

        // Inserir post
        const [result] = await db.promise().query(
            'INSERT INTO Relato (id_cliente, titulo, conteudo) VALUES (?, ?, ?)',
            [id_cliente, titulo.trim(), conteudo.trim()]
        );

        console.log(`✅ Post criado! ID: ${result.insertId}`);

        res.json({
            success: true,
            message: 'Post criado com sucesso!',
            id_relato: result.insertId
        });

    } catch (error) {
        console.error('❌ Erro ao criar post:', error);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

// 11. CURTIR POST
app.post('/api/feed/curtir', requireAuth, async (req, res) => {
    try {
        const { id_relato } = req.body;
        const userId = req.session.userId;

        console.log(`❤️ Usuário ${userId} curtiu post ${id_relato}`);

        // Verificar se post existe
        const [post] = await db.promise().query(
            'SELECT id_relato FROM Relato WHERE id_relato = ?',
            [id_relato]
        );

        if (post.length === 0) {
            return res.status(404).json({ error: 'Post não encontrado' });
        }

        // Incrementar curtidas
        const [result] = await db.promise().query(
            'UPDATE Relato SET curtidas = curtidas + 1 WHERE id_relato = ?',
            [id_relato]
        );

        if (result.affectedRows === 0) {
            return res.status(500).json({ error: 'Erro ao curtir post' });
        }

        // Buscar nova quantidade de curtidas
        const [updatedPost] = await db.promise().query(
            'SELECT curtidas FROM Relato WHERE id_relato = ?',
            [id_relato]
        );

        console.log(`✅ Post ${id_relato} curtido! Total: ${updatedPost[0].curtidas}`);

        res.json({ 
            success: true,
            message: 'Post curtido!',
            curtidas: updatedPost[0].curtidas
        });

    } catch (error) {
        console.error('❌ Erro ao curtir:', error);
        res.status(500).json({ error: 'Erro interno: ' + error.message });
    }
});

// 12. ATUALIZAR PERFIL
app.put('/api/perfil', requireAuth, async (req, res) => {
    try {
        const { nome, telefone, experiencia, descricao } = req.body;
        const userId = req.session.userId;

        // Atualizar dados básicos
        await db.promise().query(
            'UPDATE Usuario SET nome = ?, telefone = ? WHERE id_usuario = ?',
            [nome, telefone, userId]
        );

        // Se for psicólogo, atualizar dados profissionais
        const [user] = await db.promise().query(
            'SELECT tipo FROM Usuario WHERE id_usuario = ?',
            [userId]
        );

        if (user[0].tipo === 'psicologo') {
            await db.promise().query(
                'UPDATE Psicologo SET experiencia = ?, descricao = ? WHERE id_usuario = ?',
                [experiencia || 0, descricao || '', userId]
            );
        }

        res.json({
            success: true,
            message: 'Perfil atualizado com sucesso!'
        });

    } catch (error) {
        console.error('❌ Erro ao atualizar perfil:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// ==================== OUTRAS ROTAS API (mantenha as existentes) ====================

// 13. AVALIAR PSICÓLOGO
app.post('/api/avaliar', requireAuth, async (req, res) => {
    try {
        const { id_psicologo, nota, comentario } = req.body;
        const userId = req.session.userId;

        // Verificar se é cliente
        const [cliente] = await db.promise().query(
            'SELECT id_cliente FROM Cliente WHERE id_usuario = ?',
            [userId]
        );

        if (cliente.length === 0) {
            return res.status(403).json({ error: 'Apenas clientes podem avaliar' });
        }

        const id_cliente = cliente[0].id_cliente;

        // Inserir/atualizar avaliação
        const [result] = await db.promise().query(
            'INSERT INTO Avaliacao (id_cliente, id_psicologo, nota, comentario) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE nota = ?, comentario = ?',
            [id_cliente, id_psicologo, nota, comentario, nota, comentario]
        );

        // Recalcular média
        const [media] = await db.promise().query(
            'SELECT AVG(nota) as media, COUNT(*) as total FROM Avaliacao WHERE id_psicologo = ?',
            [id_psicologo]
        );

        await db.promise().query(
            'UPDATE Psicologo SET avaliacao_media = ?, total_avaliacoes = ? WHERE id_psicologo = ?',
            [media[0].media || 0, media[0].total || 0, id_psicologo]
        );

        res.json({
            success: true,
            message: 'Avaliação enviada com sucesso!'
        });

    } catch (error) {
        console.error('❌ Erro ao avaliar:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// 14. MODERADOR (simplificado)
app.get('/api/moderador/psicologos-pendentes', requireAuth, async (req, res) => {
    try {
        // Verificar se é moderador
        const [user] = await db.promise().query(
            'SELECT tipo FROM Usuario WHERE id_usuario = ?',
            [req.session.userId]
        );

        if (user[0].tipo !== 'moderador') {
            return res.status(403).json({ error: 'Acesso não autorizado' });
        }

        const [psicologos] = await db.promise().query(`
            SELECT 
                p.id_psicologo,
                p.CRP,
                p.especialidade,
                p.formacao,
                p.abordagem,
                p.experiencia,
                p.descricao,
                u.nome,
                u.email,
                u.telefone,
                u.data_cadastro
            FROM Psicologo p
            INNER JOIN Usuario u ON p.id_usuario = u.id_usuario
            WHERE p.status = 'pendente'
            ORDER BY u.data_cadastro ASC
        `);

        res.json(psicologos);
    } catch (error) {
        console.error('❌ Erro:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// 15. ROTA 404
app.use((req, res) => {
    res.status(404).json({ error: 'Rota não encontrada' });
});

// ==================== INICIAR SERVIDOR ====================
app.listen(PORT, () => {
    console.log('='.repeat(50));
    console.log(`🚀 SERVIDOR PSICOHELP RODANDO`);
    console.log(`📍 URL: http://localhost:${PORT}`);
    console.log(`🕐 ${new Date().toLocaleString()}`);
    console.log('='.repeat(50));
});