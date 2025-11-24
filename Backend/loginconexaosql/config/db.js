const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root', 
  password: '',  // ← VAZIO MESMO
  database: 'psicohelp',
  port: 3306
});

connection.connect((error) => {
  if (error) {
    console.error('❌ ERRO CONEXÃO:', error.message);
    console.log('🔧 Verifique:');
    console.log('   - XAMPP MySQL está RODANDO?');
    console.log('   - Banco "psychohelp" EXISTE?');
  } else {
    console.log('✅ CONECTADO AO MYSQL!');
  }
});

module.exports = connection;