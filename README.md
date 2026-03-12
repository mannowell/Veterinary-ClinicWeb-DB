# 🐾 Veterinary Clinic Management System — Database

> **Portfolio Project · PostgreSQL 15+ · Data Engineering**

Sistema completo de banco de dados relacional para gestão de clínicas veterinárias, desenvolvido como projeto de portfólio de Engenharia de Dados. Contempla modelagem em 3NF, automações via _triggers_, views complexas para o setor administrativo e dados de exemplo prontos para uso.

---

## 📁 Estrutura do Repositório

```
veterinary-clinic-db/
├── schema.sql     # DDL: tabelas, constraints, índices
├── triggers.sql   # 4 triggers de automação e auditoria
├── views.sql      # 3 views administrativas complexas
├── seeds.sql      # Dados de demonstração realistas
└── README.md
```

---

## 🗂️ Modelo de Dados (ERD Simplificado)

```
┌─────────────┐       ┌──────────────┐       ┌───────────────────┐
│  clientes   │──────<│     pets     │>──────│     especies      │
└─────────────┘  1:N  └──────────────┘  N:1  └───────────────────┘
                              │                        │
                              │                   ┌────────┐
                              │                   │ racas  │
                              │                   └────────┘
                              │ 1:N
                       ┌──────────────┐
                       │   consultas  │>──── medicos ──── especialidades
                       └──────────────┘>──── servicos
                              │ 1:1
                       ┌──────────────┐
                       │  prontuarios │
                       └──────────────┘
                              │ 1:N
                       ┌──────────────┐
                       │   receitas   │
                       └──────────────┘

       pets ──1:N──> vacinas <──N:1── medicos
```

---

## 📐 Normalização — Por que 3NF?

| Forma Normal | O que foi feito |
|---|---|
| **1FN** | Todos os atributos são atômicos; sem grupos repetidos ou arrays em colunas escalares |
| **2FN** | Ausência de chaves compostas desnecessárias; dependências parciais eliminadas (ex.: dados do tutor separados dos dados do pet) |
| **3FN** | Dependências transitivas removidas: `especialidade` extraída de `medicos` para tabela própria; `especie` e `raca` em tabelas de domínio; `servico` com preço centralizado, não duplicado em consultas |

**Benefícios práticos para uma clínica veterinária:**
- Atualizar o preço de um serviço reflete automaticamente em novos agendamentos, sem alterar histórico;
- Renomear uma especialidade exige alterar apenas 1 linha na tabela `especialidades`;
- Crescimento do catálogo de raças e espécies sem adicionar colunas nas tabelas principais;
- Relatórios financeiros sem risco de dados inconsistentes por redundância.

---

## 🗃️ Tabelas

| Tabela | Descrição |
|---|---|
| `especialidades` | Domínio de especialidades médicas veterinárias |
| `clientes` | Tutores/responsáveis pelos animais |
| `especies` | Domínio de espécies (canino, felino, ave…) |
| `racas` | Raças associadas à espécie |
| `pets` | Animais cadastrados na clínica |
| `medicos` | Veterinários da equipe |
| `servicos` | Catálogo de serviços e procedimentos |
| `consultas` | Agendamentos e atendimentos |
| `prontuarios` | Registro clínico detalhado por atendimento (1:1 com consulta) |
| `receitas` | Prescrições médicas (N por prontuário) |
| `vacinas` | Carteirinha de vacinação do pet |
| `log_tentativas_exclusao` | Auditoria de tentativas ilegais de exclusão |

### Principais Constraints de Integridade

- **PK** em todas as tabelas + **FK com ON UPDATE CASCADE** para consistência referencial;
- **UNIQUE** em CPF, e-mail, CRMV, microchip — evita duplicatas operacionais;
- **CHECK** em campos de domínio restrito: `status`, `sexo`, `estado`, `CPF`, `CEP`, peso, temperatura, frequências vitais;
- **NOT NULL** em todos os campos obrigatórios de negócio;
- **ON DELETE RESTRICT** protege dados clínicos históricos de exclusões acidentais em cascata.

---

## ⚡ Triggers

### `trg_atualizar_ultima_consulta`
> **Tabela:** `consultas` · **Evento:** `AFTER INSERT OR UPDATE OF status`

Atualiza automaticamente `pets.ultima_consulta` sempre que uma consulta é marcada como `concluido`. Garante que esse campo reflita sempre a data real do último atendimento sem necessidade de atualização manual pela aplicação.

---

### `trg_bloquear_exclusao_prontuario`
> **Tabela:** `prontuarios` · **Evento:** `BEFORE DELETE`

Impede a exclusão de prontuários vinculados a consultas já concluídas, em conformidade com boas práticas de prontuários veterinários (CFMV). Registra toda tentativa bloqueada na tabela `log_tentativas_exclusao` com usuário, timestamp e detalhe.

---

### `trg_calcular_valor_consulta`
> **Tabela:** `consultas` · **Evento:** `BEFORE INSERT OR UPDATE`

Calcula e preenche `valor_cobrado` automaticamente a partir de `servicos.valor_base` e do `desconto_pct` informado. Se o valor for preenchido manualmente, o trigger não intervém.

**Fórmula:** `valor_cobrado = valor_base × (1 − desconto_pct / 100)`

---

### `trg_atualizar_timestamp_prontuario` *(bônus)*
> **Tabela:** `prontuarios` · **Evento:** `BEFORE UPDATE`

Mantém `data_atualizacao` sempre sincronizado com o horário real da última modificação do prontuário.

---

## 📊 Views Administrativas

### `vw_faturamento_mensal_por_especialidade`

Relatório financeiro mensal agrupado por especialidade médica. Exibe:

| Coluna | Descrição |
|---|---|
| `mes_ano` | Período de referência (MM/YYYY) |
| `especialidade` | Especialidade do médico que atendeu |
| `total_consultas` | Volume de atendimentos |
| `pacientes_atendidos` | Pacientes únicos no período |
| `receita_bruta` | Soma dos valores-base dos serviços |
| `total_descontos` | Valor total descontado |
| `receita_liquida` | Receita efetivamente cobrada |
| `ticket_medio` | Valor médio por consulta |
| `desconto_medio_pct` | Percentual de desconto médio |
| `formas_pagamento_utilizadas` | Formas de pagamento do período |

```sql
SELECT * FROM clinica.vw_faturamento_mensal_por_especialidade;
-- Filtrando um período específico:
SELECT * FROM clinica.vw_faturamento_mensal_por_especialidade
WHERE mes_referencia >= '2025-01-01';
```

---

### `vw_historico_clinico_pet`

Linha do tempo clínica completa de cada animal. Consolida em uma única query:
- Dados cadastrais do pet e tutor
- Cada consulta com médico, serviço e valores
- Prontuário detalhado com sinais vitais
- **Receitas prescritas** agregadas em `JSONB`
- **Histórico de vacinas** agregado em `JSONB`

```sql
-- Histórico de um pet específico:
SELECT * FROM clinica.vw_historico_clinico_pet
WHERE pet_id = 1;

-- Último atendimento de cada paciente:
SELECT DISTINCT ON (pet_id) *
FROM clinica.vw_historico_clinico_pet
ORDER BY pet_id, data_consulta DESC;
```

---

### `vw_vacinas_pendentes_reforco` *(bônus)*

Alerta automático de vacinas com reforço previsto nos próximos **30 dias**, com dados de contato do tutor para notificação proativa.

```sql
SELECT * FROM clinica.vw_vacinas_pendentes_reforco;
```

---

## 🚀 Como Executar

### Pré-requisitos
- PostgreSQL 15 ou superior
- `psql` ou qualquer client (DBeaver, DataGrip, pgAdmin)

### Passo a passo

```bash
# 1. Criar o banco de dados
psql -U postgres -c "CREATE DATABASE veterinaria;"

# 2. Executar os scripts na ordem correta
psql -U postgres -d veterinaria -f schema.sql
psql -U postgres -d veterinaria -f triggers.sql
psql -U postgres -d veterinaria -f views.sql
psql -U postgres -d veterinaria -f seeds.sql
```

### Verificação rápida

```sql
-- Conectar ao banco
\c veterinaria
SET search_path TO clinica;

-- Testar faturamento
SELECT mes_ano, especialidade, receita_liquida, ticket_medio
FROM vw_faturamento_mensal_por_especialidade;

-- Testar histórico clínico
SELECT nome_pet, nome_tutor, data_consulta, diagnostico
FROM vw_historico_clinico_pet
WHERE nome_pet = 'Thor';

-- Verificar vacinas pendentes
SELECT * FROM vw_vacinas_pendentes_reforco;

-- Conferir ultima_consulta atualizada via trigger
SELECT nome, ultima_consulta FROM pets ORDER BY ultima_consulta DESC;
```

---

## 🛡️ Decisões de Design

- **Schema dedicado `clinica`**: isola o projeto de outros schemas e facilita permissões granulares por role;
- **TIMESTAMPTZ** em `consultas.data_hora`: armazena fuso horário, essencial para clínicas com múltiplas unidades;
- **JSONB nas views**: receitas e vacinas são agregadas em JSON dentro da view, mantendo 3NF nas tabelas base e entregando payload pronto para APIs;
- **Índices seletivos**: `idx_vacinas_reforco` usa `WHERE data_reforco IS NOT NULL` evitando índice parcial desnecessário;
- **log_tentativas_exclusao**: auditoria persistente com `current_user` do PostgreSQL, sem depender de camada de aplicação.

---

## 📄 Licença

MIT License — livre para uso em portfólio, estudos e adaptações comerciais com atribuição.
