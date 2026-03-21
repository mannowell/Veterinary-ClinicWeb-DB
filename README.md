# VetAdmin - Sistema de Gestão Veterinária 🐾

Sistema para gestão de clínicas veterinárias, focado em alta performance, normalização de dados (3NF) e uma experiência de usuário premium com design **Dark Mode Glassmorphism**.

> **Painel Administrativo para controle total de prontuários, faturamento e saúde animal.**

## 🚀 Funcionalidades Principais

### 🩺 Módulo Clínico & Atendimento
- **Prontuário Digital:** Registro completo de anamnese, exame físico e evolução clínica.
- **Prescrições Inteligentes:** Emissão de receitas com dosagem e frequência integradas ao prontuário.
- **Histórico do Pet:** Acesso rápido a vacinas e consultas anteriores.

### 💰 Gestão Financeira & Agendamentos
- **Cálculo em Tempo Real:** Visualização de valores de serviços com aplicação de descontos dinâmica.
- **Auditoria Financeira:** Registro do valor cobrado no momento da conclusão para integridade histórica.
- **Filtros Inteligentes:** Gestão de status (Agendado, Em Atendimento, Concluído, Cancelado).

### 🎨 UX & Inteligência
- **Dashboard Interativo:** Cards de resumo clicáveis para navegação rápida.
- **Automações:** 
  - Busca de endereço automática via **ViaCEP API**.
  - Máscaras de CPF e Telefone.
  - Cálculo de idade automático a partir da data de nascimento (e vice-versa).
- **Design Glassmorphism:** Interface moderna com transparências, desfoque de fundo e fontes Inter.

## 🛠️ Tecnologias Utilizadas

- **Frontend:** HTML5, CSS3 (Vanilla), JavaScript (ES6+).
- **Backend:** Node.js, Express.
- **Banco de Dados:** PostgreSQL 15+ (Arquitetura 3NF).
- **Gráficos:** Chart.js.

## ⚙️ Instalação e Configuração

Para rodar o projeto localmente, você precisará inicializar o Backend e o Banco de Dados antes de abrir o Frontend.

### 1. Banco de Dados (PostgreSQL)
Certifique-se de ter o PostgreSQL instalado. Execute o script de criação no seu terminal ou ferramenta de gerenciamento (pgAdmin/DBeaver):
```bash
psql -U postgres -f backend/schema.sql
```

### 2. Backend (Node.js API)
Navegue até a pasta backend, instale as dependências e inicie o servidor:
```bash
cd backend
npm install
node server.js
```
*O servidor deve iniciar na porta de desenvolvimento configurada.*

### 3. Frontend (Client UI)
O frontend não requer servidor Node. Você deve abrir o arquivo estático diretamente ou usar um servidor simples:
- Abra o `frontend/index.html` no seu navegador 
- OU utilize a extensão *Live Server* do VSCode.
*(Certifique-se de que o backend já esteja rodando para que as chamadas de API do frontend funcionem corretamente).*

---

## 🏛️ Arquitetura de Dados (3NF)
O projeto segue rigorosamente a **Terceira Forma Normal**, garantindo:
- Eliminação de redundâncias.
- Integridade referencial forte.
- Desempenho otimizado através de índices estratégicos em datas e status.

---
**Desenvolvido por Wellison** - *Portfolio de Engenharia de Dados & Fullstack*
