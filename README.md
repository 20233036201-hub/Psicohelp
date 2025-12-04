Como fazer o Psicohelp rodar?

1- crie uma pasta no seu VS e abra o terminal dela.
2- digite no terminal: git clone https://github.com/20233036201-hub/Psicohelp.git
3- digte no terminal: cd \psicohelp
4- depois digite npm install
5- agora crie o bd no seu Mysql (o arquivo ".sql" que já esta no projeto)
6- crie o ".env" e configure da seguinte forma:
# .env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=TUA_SENHA_AQUI
DB_NAME=psicohelp
DB_PORT=3306

PORT=3000
SESSION_SECRET=psicohelp-session-secret-2025
CORS_ORIGINS=http://localhost:3000,http://localhost:5500,http://127.0.0.1:5500
7- digite "npm start" no terminal e pronto!
