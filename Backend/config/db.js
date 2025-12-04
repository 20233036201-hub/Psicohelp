// config/db.js
const mysql = require('mysql2');
require('dotenv').config();
// Função para verificar autenticação em páginas HTML
const checkAuthAndRedirect = async (req, res, next) => {
    if (!req.session.userId) {
        return res.redirect('/');
    }
    next();
};
const connection = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'psicohelp',
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

connection.getConnection((err, conn) => {
    if (err) {
        console.error('❌ ERRO AO CONECTAR AO BANCO:', err.message);
        console.log('🔧 Verifique:');
        console.log('1. MySQL está rodando?');
        console.log('2. Banco "psicohelp" existe?');
        console.log('3. Credenciais no .env estão corretas?');
    } else {
        console.log('✅ CONEXÃO COM BANCO ESTABELECIDA');
        console.log(`📊 Banco: ${process.env.DB_NAME || 'psicohelp'}`);
        conn.release();
    }
});

module.exports = connection;