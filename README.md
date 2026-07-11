# VetAdmin — Sistema de Gestão Veterinária

> **Painel Administrativo** para controle total de prontuários, faturamento e saúde animal. Sistema completo com backend Node.js, frontend vanilla e banco PostgreSQL normalizado em 3NF.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791.svg)](https://www.postgresql.org/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933.svg)](https://nodejs.org/)
[![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-F7DF1E.svg)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)

---

## Funcionalidades Principais

### Modulo Clinico & Atendimento
- **Prontuario Digital:** Registro completo de anamnese, exame fisico e evolucao clinica
- **Prescricoes Inteligentes:** Emissao de receitas com dosagem e frequencia integradas
- **Historico do Pet:** Acesso rapido a vacinas e consultas anteriores

### Gestao Financeira & Agendamentos
- **Calculo em Tempo Real:** Visualizacao de valores com descontos dinamicos
- **Auditoria Financeira:** Registro do valor cobrado no momento da conclusao
- **Filtros Inteligentes:** Status (Agendado, Em Atendimento, Concluido, Cancelado)

### UX & Inteligencia
- **Dashboard Interativo:** Cards de resumo clicaveis
- **Automacoes:** ViaCEP API, mascaras CPF/Telefone, calculo de idade automatico
- **Design Glassmorphism:** Interface moderna com transparencias e desfoque

---

## Tecnologias

| Camada | Tecnologia |
|--------|------------|
| Frontend | HTML5, CSS3 (Vanilla), JavaScript (ES6+) |
| Backend | Node.js, Express |
| Banco de Dados | PostgreSQL 15+ (3NF) |
| Graficos | Chart.js |
| API Externa | ViaCEP (busca de endereco) |

---

## Instalacao

### Pre-requisitos
- Node.js 18+
- PostgreSQL 15+

### 1. Banco de Dados
```bash
psql -U postgres -c "CREATE DATABASE veterinaria;"
psql -U postgres -d veterinaria -f backend/schema.sql
psql -U postgres -d veterinaria -f backend/triggers.sql
psql -U postgres -d veterinaria -f backend/views.sql
psql -U postgres -d veterinaria -f backend/seeds.sql
```

### 2. Backend
```bash
cd backend
npm install
cp ../.env.example ../.env   # edite as credenciais do banco
npm start
```

### 3. Frontend
```bash
# Opcao 1: Abrir diretamente
open frontend/index.html

# Opcao 2: Live Server (VSCode)
# Instalar extensao Live Server e clicar em "Go Live"
```

---

## Arquitetura de Dados (3NF)

O projeto segue rigorosamente a **Terceira Forma Normal**:
- Eliminacao de redundancias
- Integridade referencial forte
- Desempenho otimizado com indices estrategicos

### Tabelas do Sistema

| Tabela | Descricao |
|--------|-----------|
| `especialidades` | Dominio de especialidades medicas veterinarias |
| `clientes` | Tutores/responsaveis pelos animais |
| `especies` | Especies animais (canino, felino, ave...) |
| `racas` | Racas vinculadas a especie |
| `pets` | Animais cadastrados na clinica |
| `medicos` | Veterinarios da equipe |
| `servicos` | Catalogo de servicos e procedimentos |
| `consultas` | Agendamentos e atendimentos |
| `prontuarios` | Registro clinico detalhado (1:1 com consulta) |
| `receitas` | Prescricoes medicas (N por prontuario) |
| `vacinas` | Carteirinha de vacinacao do pet |

---

## Estrutura do Projeto

```
ClinicWeb/
├── .env.example
├── backend/
│   ├── server.js          # Express API
│   ├── package.json
│   ├── schema.sql         # DDL (criacao de tabelas)
│   ├── seeds.sql          # Dados de exemplo
│   ├── triggers.sql       # Automacoes no banco
│   └── views.sql          # Views para relatorios
├── frontend/
│   ├── index.html         # Dashboard principal
│   ├── agendamentos.html  # Gerenciamento de consultas
│   ├── pets.html          # Gerenciamento de animais
│   ├── clientes.html      # Gerenciamento de clientes
│   ├── medicos.html       # Gerenciamento de medicos
│   ├── servicos.html      # Gerenciamento de servicos
│   ├── app.js             # Logica de agendamentos
│   └── style.css          # Estilos (Glassmorphism)
└── README.md
```

---

## API Endpoints

| Metodo | Rota | Descricao |
|--------|------|-----------|
| GET | `/api/stats` | Estatisticas do dashboard |
| GET | `/api/faturamento` | Dados do grafico de receita |
| GET/POST | `/api/clientes` | Listar/criar clientes |
| PUT | `/api/clientes/:id` | Atualizar cliente |
| GET/POST | `/api/pets` | Listar/criar pets |
| PUT | `/api/pets/:id` | Atualizar pet |
| GET/POST | `/api/medicos` | Listar/criar medicos |
| PUT | `/api/medicos/:id` | Atualizar medico |
| GET/POST | `/api/servicos` | Listar/criar servicos |
| PUT | `/api/servicos/:id` | Atualizar servico |
| GET/POST | `/api/consultas` | Listar/criar consultas |
| PUT | `/api/consultas/:id` | Atualizar consulta |
| GET/POST | `/api/consultas/:id/prontuario` | Obter/criar prontuario |
| GET/POST | `/api/prontuarios/:id/receitas` | Listar/criar receitas |
| GET | `/api/pets/:id/historico` | Historico completo do pet |
| POST | `/api/pets/:id/vacinas` | Registrar vacina |
| GET | `/api/especies` | Listar especies |
| GET | `/api/especialidades` | Listar especialidades |
| GET | `/api/racas` | Listar racas (filtrar por especie_id) |

---

## Licenca

Distribuido sob licenca **MIT**.

---

## Autor

**Wellison Oliveira (Mannowell)** — Desenvolvedor Full Stack & AI Automation Developer

- [GitHub](https://github.com/mannowell)
- [LinkedIn](https://linkedin.com/in/wellison-nascimento-79ba6b65/)
- [Email](mailto:manofama@gmail.com)

---

> Projeto de portfolio — Demonstracao de habilidades em modelagem de dados (3NF), desenvolvimento fullstack e design de interfaces.
