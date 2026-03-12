# VetAdmin - Sistema de Gestão Veterinária 🐾

Sistema completo para gestão de clínicas veterinárias, focado em alta performance, normalização de dados (3NF) e uma experiência de usuário premium com design **Dark Mode Glassmorphism**.

![Dashboard Preview](https://via.placeholder.com/800x450/0d1117/58a6ff?text=VetAdmin+Glassmorphism+Interface)

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

### 1. Banco de Dados (PostgreSQL)
Certifique-se de ter o PostgreSQL instalado. Execute o script de criação no seu terminal ou ferramenta de gerenciamento (pgAdmin/DBeaver):
```bash
psql -U postgres -f backend/schema.sql
```

### 2. Backend (Node.js)
Navegue até a pasta backend e instale as dependências:
```bash
cd backend
npm install
node server.js
```

### 3. Frontend
O frontend é composto por arquivos estáticos. Basta abrir o `frontend/index.html` no seu navegador ou utilizar uma extensão como *Live Server*.

---

## 🏛️ Arquitetura de Dados (3NF)
O projeto segue rigorosamente a **Terceira Forma Normal**, garantindo:
- Eliminação de redundâncias.
- Integridade referencial forte.
- Desempenho otimizado através de índices estratégicos em datas e status.

---
**Desenvolvido por Wellison** - *Portfolio de Engenharia de Dados & Fullstack*
