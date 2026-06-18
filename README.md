# 🐾 VetAdmin — Sistema de Gestão Veterinária

> **Painel Administrativo** para controle total de prontuários, faturamento e saúde animal. Sistema completo com backend Node.js, frontend vanilla e banco PostgreSQL normalizado em 3NF.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://www.postgresql.org/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933.svg)](https://nodejs.org/)
[![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-F7DF1E.svg)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)

---

## 📸 Preview

| Dashboard | Prontuário | Agendamento |
|-----------|------------|-------------|
| ![Dashboard](docs/screenshots/dashboard.png) | ![Prontuário](docs/screenshots/prontuario.png) | ![Agendamento](docs/screenshots/agendamento.png) |

---

## 🚀 Funcionalidades Principais

### 🩺 Módulo Clínico & Atendimento
- **Prontuário Digital:** Registro completo de anamnese, exame físico e evolução clínica
- **Prescrições Inteligentes:** Emissão de receitas com dosagem e frequência integradas
- **Histórico do Pet:** Acesso rápido a vacinas e consultas anteriores

### 💰 Gestão Financeira & Agendamentos
- **Cálculo em Tempo Real:** Visualização de valores com descontos dinâmicos
- **Auditoria Financeira:** Registro do valor cobrado no momento da conclusão
- **Filtros Inteligentes:** Status (Agendado, Em Atendimento, Concluído, Cancelado)

### 🎨 UX & Inteligência
- **Dashboard Interativo:** Cards de resumo clicáveis
- **Automações:** ViaCEP API, máscaras CPF/Telefone, cálculo de idade automático
- **Design Glassmorphism:** Interface moderna com transparências e desfoque

---

## 🛠️ Tecnologias

| Camada | Tecnologia |
|--------|------------|
| Frontend | HTML5, CSS3 (Vanilla), JavaScript (ES6+) |
| Backend | Node.js, Express |
| Banco de Dados | PostgreSQL 15+ (3NF) |
| Gráficos | Chart.js |
| API Externa | ViaCEP (busca de endereço) |

---

## ⚙️ Instalação

### Pré-requisitos
- Node.js 18+
- PostgreSQL 15+

### 1. Banco de Dados
```bash
psql -U postgres -f backend/schema.sql
```

### 2. Backend
```bash
cd backend
npm install
node server.js
```

### 3. Frontend
```bash
# Opção 1: Abrir diretamente
open frontend/index.html

# Opção 2: Live Server (VSCode)
# Instalar extensão Live Server e clicar em "Go Live"
```

---

## 🏛️ Arquitetura de Dados (3NF)

O projeto segue rigorosamente a **Terceira Forma Normal**:

- ✅ Eliminação de redundâncias
- ✅ Integridade referencial forte
- ✅ Desempenho otimizado com índices estratégicos

### Entidades Principais

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   TUTOR     │────<│    PET      │────<│  CONSULTA   │
├─────────────┤     ├─────────────┤     ├─────────────┤
│ id          │     │ id          │     │ id          │
│ nome        │     │ tutor_id    │     │ pet_id      │
│ cpf         │     │ nome        │     │ data        │
│ telefone    │     │ especie     │     │ diagnostico │
│ endereco    │     │ raca        │     │ prescricao  │
└─────────────┘     │ nascimento  │     │ valor       │
                    └─────────────┘     └─────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │   VACINA    │
                    ├─────────────┤
                    │ id          │
                    │ pet_id      │
                    │ nome        │
                    │ data        │
                    └─────────────┘
```

### Tabelas do Sistema

| Tabela | Descrição |
|--------|-----------|
| `tutores` | Dados dos donos dos pets |
| `pets` | Dados dos animais |
| `consultas` | Registros de atendimentos |
| `prescricoes` | Receitas e prescrições |
| `vacinas` | Controle de vacinação |
| `servicos` | Catálogo de serviços |
| `agendamentos` | Agenda de consultas |
| `faturamento` | Registro financeiro |

---

## 📁 Estrutura do Projeto

```
ClinicWeb/
├── backend/
│   ├── server.js          # Express API
│   ├── schema.sql         # DDL (criação de tabelas)
│   ├── seeds.sql          # Dados de exemplo
│   ├── triggers.sql       # Automações no banco
│   └── views.sql          # Views para relatórios
├── frontend/
│   ├── index.html         # Dashboard principal
│   ├── css/               # Estilos (Glassmorphism)
│   └── js/                # Lógica (Vanilla JS)
├── docs/
│   └── screenshots/       # Screenshots do sistema
└── README.md
```

---

## 🤝 Contribuindo

1. Fork o projeto
2. Crie branch: `git checkout -b feature/nova-funcionalidade`
3. Commit: `git commit -m 'feat: adiciona nova funcionalidade'`
4. Push: `git push origin feature/nova-funcionalidade`
5. Abra Pull Request

---

## 📄 Licença

Distribuído sob licença **MIT**.

---

## 👤 Autor

**Wellison Oliveira (Mannowell)** — Desenvolvedor Full Stack & AI Automation Developer

- 🌐 [GitHub](https://github.com/mannowell)
- 💼 [LinkedIn](https://linkedin.com/in/wellison-nascimento-79ba6b65/)
- 📧 [Email](mailto:manofama@gmail.com)
- 🔗 [Portfolio](https://mannowell.github.io/Portifolio/)
- 💼 [Upwork](https://www.upwork.com/freelancers/~YOUR_ID)

---

> 📌 **Projeto de portfólio** — Demonstração de habilidades em modelagem de dados (3NF), desenvolvimento fullstack e design de interfaces.
