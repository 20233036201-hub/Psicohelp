// frontend/navbar.js
async function atualizarNavbar() {
    try {
        const response = await fetch('/api/usuario/atual', {
            credentials: 'include'
        });
        
        if (response.status === 401) return;
        
        const user = await response.json();
        
        // Esconder botões baseados no tipo de usuário
        if (user.tipo === 'psicologo') {
            // Esconder botão Agendar
            const btnsAgendar = document.querySelectorAll('.nav-btn');
            btnsAgendar.forEach(btn => {
                if (btn.textContent.includes('Agendar') || btn.onclick?.toString().includes('agendar')) {
                    btn.style.display = 'none';
                }
            });
            
            // Modificar botão Consultas para "Meus Pacientes"
            const btnsConsultas = document.querySelectorAll('.nav-btn');
            btnsConsultas.forEach(btn => {
                if (btn.textContent.includes('Consultas') || btn.onclick?.toString().includes('minhas_consultas')) {
                    btn.textContent = '📋 Meus Pacientes';
                    btn.onclick = function() {
                        window.location.href = '/psicologo/consultas';
                    };
                }
            });
        }
    } catch (error) {
        console.error('Erro ao atualizar navbar:', error);
    }
}

// Executar quando a página carregar
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', atualizarNavbar);
} else {
    atualizarNavbar();
}