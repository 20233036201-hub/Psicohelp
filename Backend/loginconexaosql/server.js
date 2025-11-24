const express = require('express');
const cors = require('cors');
const path = require('path');
const db = require('./config/db');
const bcrypt = require('bcryptjs');

const app = express();
const PORT = 3000;

// ==================== MIDDLEWARES ====================
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use((req, res, next) => {
    res.setHeader('Cache-Control', 'no-cache');
    next();
});

// SERVIR FRONTEND COMPLETO
app.use(express.static(path.join(__dirname, '..', '..', 'frontend', 'login')));
app.use(express.static(path.join(__dirname, '..', '..', 'frontend')));

// ==================== ROTAS DE PÁGINAS HTML ====================

// LOGIN (página inicial)
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '..', '..', 'frontend', 'login', 'index.html'));
});


// HOME / FEED
app.get('/home', (req, res) => {
    res.sendFile(path.join(__dirname, '..', '..', 'frontend', 'home', 'pfi_home_feed.html'));
});

// PERFIL
app.get('/perfil', (req, res) => {
    res.sendFile(path.join(__dirname, '..', '..', 'frontend', 'perfil', 'index.html'));
});

// AGENDAR CONSULTA
app.get('/agendar', (req, res) => {
    res.sendFile(path.join(__dirname, '..', '..', 'frontend', 'agendar', 'index.html'));
});

// CADASTRO CLIENTE
app.get('/cadastro/cliente', (req, res) => {
    res.sendFile(path.join(__dirname, '..', '..', 'frontend', 'cadastro_cliente', 'index.html'));
});

// CADASTRO PSICÓLOGO
app.get('/cadastro/psicologo', (req, res) => {
    res.sendFile(path.join(__dirname, '..', '..', 'frontend', 'cadastro_psicologo', 'index.html'));
});

// MINHAS CONSULTAS
app.get('/minhas_consultas', (req, res) => {
    res.sendFile(path.join(__dirname, '..', '..', 'frontend', 'minhas_consultas(PAC)', 'index.html'));
});

// CONFIRMAR AGENDAMENTO - PÁGINA REAL
app.get('/confirmar_agendamento', (req, res) => {
    res.sendFile(path.join(__dirname, '..', '..', 'frontend', 'confirmar_agendamento', 'index.html'));
});

// ==================== ROTAS API ====================

// CADASTRO - CORRIGIDO
app.post('/api/cadastro', async (req, res) => {
    const { nome, email, senha, tipo, crp, especialidade, formacao, abordagem, experiencia, sobre, telefone } = req.body;

    try {
        console.log('🟡 DADOS RECEBIDOS NO CADASTRO:', {
            nome, email, tipo, crp, especialidade, 
            formacao, abordagem, experiencia, sobre, telefone
        });

        // Verifica se email já existe
        const [users] = await db.promise().query('SELECT * FROM Usuario WHERE email = ?', [email]);
        if (users.length > 0) {
            return res.status(400).json({ error: 'Email já cadastrado' });
        }

        // Cria usuário
        const hashedPassword = await bcrypt.hash(senha, 10);
        const [userResult] = await db.promise().query(
            'INSERT INTO Usuario (nome, email, senha, tipo, telefone) VALUES (?, ?, ?, ?, ?)',
            [nome, email, hashedPassword, tipo, telefone || 'Não informado']
        );

        const userId = userResult.insertId;

        if (tipo === 'psicologo') {
            // INSERE PSICÓLOGO COM TODOS OS CAMPOS
            await db.promise().query(
                `INSERT INTO Psicologo 
                 (id_usuario, CRP, especialidade, formacao, abordagem, experiencia, descricao, status) 
                 VALUES (?, ?, ?, ?, ?, ?, ?, "ativo")`,
                [userId, crp, especialidade, formacao, abordagem, experiencia, sobre]
            );

            console.log('🟢 Psicólogo cadastrado com sucesso:', nome);
            res.json({
                success: true,
                message: 'Psicólogo cadastrado com sucesso!'
            });
        } else {
            // 🔥 CORREÇÃO: CADASTRO SIMPLES SEM STATUS
            await db.promise().query(
                `INSERT INTO Cliente (id_usuario) VALUES (?)`,
                [userId]
            );

            console.log('🟢 Cliente cadastrado com sucesso:', nome);
            res.json({
                success: true,
                message: 'Cliente cadastrado com sucesso!'
            });
        }

    } catch (error) {
        console.error('🔴 Erro no cadastro:', error);
        res.status(500).json({ 
            error: 'Erro interno do servidor',
            details: error.message 
        });
    }
});

// LOGIN
app.post('/api/login', async (req, res) => {
    const { email, senha } = req.body;

    try {
        const [users] = await db.promise().query('SELECT * FROM Usuario WHERE email = ?', [email]);

        if (users.length === 0)
            return res.status(400).json({ error: 'Email não encontrado' });

        const user = users[0];
        const validPassword = await bcrypt.compare(senha, user.senha);

        if (!validPassword)
            return res.status(400).json({ error: 'Senha incorreta' });

        res.json({
            success: true,
            message: 'Login realizado com sucesso!',
            redirect: '/home',
            user: {
                id: user.id_usuario,
                nome: user.nome,
                email: user.email,
                tipo: user.tipo
            }
        });

    } catch (error) {
        console.error('Erro no login:', error);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

app.get('/api/psicologos', async (req, res) => {
    try {
        console.log('🔵 Buscando psicólogos completos...');
        
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
                p.telefone,
                p.status,
                u.nome,
                u.email
            FROM Psicologo p
            JOIN Usuario u ON p.id_usuario = u.id_usuario
        `);
        
        console.log('🟢 Psicólogos encontrados:', psicologos.length);
        console.log('Campos do primeiro psicólogo:', Object.keys(psicologos[0] || {}));
        
        res.json(psicologos);
        
    } catch (error) {
        console.log('🔴 Erro na API:', error);
        res.json([]);
    }
});

// Rota para criar agendamento - CORRIGIDA (SEM TIPO)
app.post('/api/agendamentos', async (req, res) => {
    const { id_psicologo, data, horario, observacoes } = req.body;

    try {
        console.log('🟡 Novo agendamento:', { id_psicologo, data, horario, observacoes });

        // ID temporário do cliente (depois pega da sessão)
        const id_cliente = 1; // TEMPORÁRIO

        // Insere o agendamento SEM o campo "tipo"
        const [result] = await db.promise().query(
            `INSERT INTO Consulta (id_cliente, id_psicologo, data_consulta, horario, observacoes, status) 
             VALUES (?, ?, ?, ?, ?, 'agendada')`,
            [id_cliente, id_psicologo, data, horario, observacoes]
        );

        console.log('🟢 Agendamento criado com ID:', result.insertId);
        
        res.json({
            success: true,
            message: 'Consulta agendada com sucesso!',
            id_consulta: result.insertId
        });

    } catch (error) {
        console.error('🔴 Erro no agendamento:', error);
        res.status(500).json({ 
            error: 'Erro interno do servidor',
            details: error.message 
        });
    }
});

// CONFIRMAR AGENDAMENTO - ROTA ÚNICA
app.get('/confirmar_agendamento', (req, res) => {
    console.log('✅ ROTA /confirmar_agendamento ACESSADA!');
    console.log('📋 Parâmetros:', req.query);
    
    res.sendFile(path.join(__dirname, '..', '..', 'frontend', 'confirmar_agendamento', 'index.html'));
});

// MINHAS CONSULTAS API - CORRIGIDA (BUSCA NA TABELA CORRETA)
app.get('/api/minhas-consultas/:id', async (req, res) => {
    try {
        const userId = req.params.id;
        console.log('🔵 Buscando consultas para usuário:', userId);

        // Busca consultas do cliente na tabela CONSULTA
        const [consultas] = await db.promise().query(`
            SELECT 
                c.id_consulta,
                c.data_consulta,
                c.horario,
                c.observacoes,
                c.status,
                u.nome AS nome_psicologo,
                p.especialidade,
                p.telefone AS telefone_psicologo
            FROM Consulta c
            JOIN Psicologo p ON c.id_psicologo = p.id_psicologo
            JOIN Usuario u ON p.id_usuario = u.id_usuario
            WHERE c.id_cliente = ?
            ORDER BY c.data_consulta DESC, c.horario DESC
        `, [userId]);

        console.log('🟢 Consultas encontradas:', consultas.length);
        
        res.json(consultas);

    } catch (error) {
        console.error('🔴 Erro ao buscar consultas:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// PERFIL DO USUÁRIO
app.get('/api/usuario/:id', async (req, res) => {
    try {
        const userId = req.params.id;

        const [users] = await db.promise().query(`
            SELECT u.*, p.CRP, p.especialidade, p.telefone
            FROM Usuario u
            LEFT JOIN Psicologo p ON u.id_usuario = p.id_usuario
            WHERE u.id_usuario = ?
        `, [userId]);

        if (users.length === 0)
            return res.status(404).json({ error: 'Usuário não encontrado' });

        res.json(users[0]);

    } catch (error) {
        console.error('Erro ao buscar usuário:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// FEED – CARREGAR POSTS
app.get('/api/feed', async (req, res) => {
    try {
        const [posts] = await db.promise().query(`
            SELECT r.*, u.nome AS nome_cliente
            FROM relato r
            JOIN usuario u ON r.id_cliente = u.id_usuario
            ORDER BY r.data_postagem DESC
        `);

        res.json(posts);

    } catch (error) {
        console.error('Erro ao buscar feed:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// FEED – CRIAR POST - CORRIGIDO
app.post('/api/feed/post', async (req, res) => {
    try {
        const { titulo, conteudo } = req.body;
        const id_cliente = 1; // temporário

        console.log('🟡 Criando novo post:', { titulo, conteudo });

        const [result] = await db.promise().query(
            'INSERT INTO relato (id_cliente, titulo, conteudo, data_postagem, curtidas) VALUES (?, ?, ?, NOW(), 0)',
            [id_cliente, titulo, conteudo]
        );

        console.log('🟢 Post criado com ID:', result.insertId);
        
        res.json({ 
            success: true, 
            id_relato: result.insertId,
            message: 'Post criado com sucesso!'
        });

    } catch (error) {
        console.error('🔴 Erro ao criar post:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// FEED – CURTIR / DESCURTIR
app.post('/api/feed/curtir', async (req, res) => {
    try {
        const { id_relato } = req.body;
        const id_usuario = 1;

        const [jaCurtiu] = await db.promise().query(
            'SELECT * FROM curtida WHERE id_relato = ? AND id_usuario = ?',
            [id_relato, id_usuario]
        );

        if (jaCurtiu.length > 0) {
            await db.promise().query(
                'DELETE FROM curtida WHERE id_relato = ? AND id_usuario = ?',
                [id_relato, id_usuario]
            );
            await db.promise().query(
                'UPDATE relato SET curtidas = curtidas - 1 WHERE id_relato = ?',
                [id_relato]
            );
        } else {
            await db.promise().query(
                'INSERT INTO curtida (id_relato, id_usuario) VALUES (?, ?)',
                [id_relato, id_usuario]
            );
            await db.promise().query(
                'UPDATE relato SET curtidas = curtidas + 1 WHERE id_relato = ?',
                [id_relato]
            );
        }

        res.json({ success: true });

    } catch (error) {
        console.error('Erro ao curtir:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// ==================== START SERVER ====================
db.connect((error) => {
    if (error) {
        console.error('❌ ERRO CONECTANDO AO BANCO:', error.message);
    } else {
        console.log('✅ CONECTADO AO MYSQL - Banco: psychohelp');
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Servidor rodando na porta ${PORT}`);
    console.log(`📍 Local: http://localhost:${PORT}`);
    console.log(`📍 Rede: http://192.168.3.140:${PORT}`);
});