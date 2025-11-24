const express = require('express');
const router = express.Router();
const db = require('../config/db');
const bcrypt = require('bcryptjs');

// CADASTRO DE USUÁRIO
router.post('/cadastro', async (req, res) => {
  const { nome, email, senha, tipo, crp, formacao } = req.body;

  try {
    // Verifica se email já existe
    const [users] = await db.promise().query('SELECT * FROM Usuario WHERE email = ?', [email]);
    
    if (users.length > 0) {
      return res.status(400).json({ error: 'Email já cadastrado' });
    }

    // Criptografa a senha
    const hashedPassword = await bcrypt.hash(senha, 10);

    // Insere usuário
    const [result] = await db.promise().query(
      'INSERT INTO Usuario (nome, email, senha, tipo) VALUES (?, ?, ?, ?)',
      [nome, email, hashedPassword, tipo]
    );

    const userId = result.insertId;

    // Se for psicólogo
    if (tipo === 'psicologo') {
      await db.promise().query(
        'INSERT INTO Psicologo (id_usuario, CRP, especialidade) VALUES (?, ?, ?)',
        [userId, crp, formacao]
      );
      res.json({ success: true, message: 'Psicólogo cadastrado com sucesso!' });
    } 
    // Se for cliente
    else {
      await db.promise().query(
        'INSERT INTO Cliente (id_usuario) VALUES (?)',
        [userId]
      );
      res.json({ success: true, message: 'Cliente cadastrado com sucesso!' });
    }

  } catch (error) {
    console.error('Erro no cadastro:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// LOGIN DE USUÁRIO
router.post('/login', async (req, res) => {
  const { email, senha } = req.body;

  try {
    const [users] = await db.promise().query('SELECT * FROM Usuario WHERE email = ?', [email]);
    
    if (users.length === 0) {
      return res.status(400).json({ error: 'Email não encontrado' });
    }

    const user = users[0];
    const validPassword = await bcrypt.compare(senha, user.senha);
    
    if (!validPassword) {
      return res.status(400).json({ error: 'Senha incorreta' });
    }

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
    console.error('Erro no login:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

module.exports = router;

