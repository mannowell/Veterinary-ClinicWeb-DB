-- =============================================================================
-- SISTEMA DE GESTÃO DE CLÍNICAS VETERINÁRIAS
-- Banco de Dados: PostgreSQL 15+
-- Normalização: Terceira Forma Normal (3NF)
-- Autor: WELLISON - Portfolio - Engenharia de Dados
-- Data: 2026-03-12
-- =============================================================================
-- NORMALIZAÇÃO EM 3NF:
--   1FN: Todos os atributos são atômicos; sem grupos repetidos.
--   2FN: Chaves compostas eliminadas onde possível; dependências parciais
--        removidas (ex.: dados do tutor separados do pet).
--   3FN: Dependências transitivas eliminadas (ex.: especialidade do médico
--        em tabela própria; endereço do cliente em tabela dedicada para
--        clientes com múltiplos endereços). Cada tabela representa um e apenas
--        um conceito de negócio, evitando redundância e anomalias de atualização.
-- =============================================================================

-- Extensão para geração de UUID
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- SCHEMA DEDICADO
-- =============================================================================
CREATE SCHEMA IF NOT EXISTS clinica;
SET search_path TO clinica;

-- =============================================================================
-- 1. TABELA: especialidades
--    Domínio controlado de especialidades médicas veterinárias.
--    Separada para eliminar dependência transitiva em medicos.
-- =============================================================================
CREATE TABLE especialidades (
    id            SERIAL       PRIMARY KEY,
    nome          VARCHAR(100) NOT NULL,
    descricao     TEXT,
    CONSTRAINT uq_especialidade_nome UNIQUE (nome)
);

-- =============================================================================
-- 2. TABELA: clientes
--    Tutores/responsáveis pelos animais.
-- =============================================================================
CREATE TABLE clientes (
    id              SERIAL        PRIMARY KEY,
    nome            VARCHAR(150)  NOT NULL,
    cpf             CHAR(11)      NOT NULL,
    email           VARCHAR(200)  NOT NULL,
    telefone        VARCHAR(20)   NOT NULL,
    logradouro      VARCHAR(200),
    numero          VARCHAR(10),
    bairro          VARCHAR(100),
    cidade          VARCHAR(100),
    estado          CHAR(2),
    cep             CHAR(8),
    data_cadastro   DATE          NOT NULL DEFAULT CURRENT_DATE,
    ativo           BOOLEAN       NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_cliente_cpf   UNIQUE (cpf),
    CONSTRAINT uq_cliente_email UNIQUE (email),
    CONSTRAINT ck_cliente_estado CHECK (estado IS NULL OR estado ~ '^[A-Z]{2}$'),
    CONSTRAINT ck_cliente_cpf   CHECK (cpf ~ '^\d{11}$'),
    CONSTRAINT ck_cliente_cep   CHECK (cep IS NULL OR cep ~ '^\d{8}$')
);

-- =============================================================================
-- 3. TABELA: especies
--    Domínio controlado de espécies animais.
-- =============================================================================
CREATE TABLE especies (
    id     SERIAL      PRIMARY KEY,
    nome   VARCHAR(80) NOT NULL,
    CONSTRAINT uq_especie_nome UNIQUE (nome)
);

-- =============================================================================
-- 4. TABELA: racas
--    Raças vinculadas à espécie (elimina redundância em pets).
-- =============================================================================
CREATE TABLE racas (
    id          SERIAL      PRIMARY KEY,
    especie_id  INT         NOT NULL,
    nome        VARCHAR(100) NOT NULL,
    CONSTRAINT fk_raca_especie FOREIGN KEY (especie_id)
        REFERENCES especies (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_raca_especie_nome UNIQUE (especie_id, nome)
);

-- =============================================================================
-- 5. TABELA: pets
--    Animais cadastrados; cada pet pertence a um cliente.
-- =============================================================================
CREATE TABLE pets (
    id                      SERIAL        PRIMARY KEY,
    cliente_id              INT           NOT NULL,
    especie_id              INT           NOT NULL,
    raca_id                 INT,
    nome                    VARCHAR(100)  NOT NULL,
    data_nascimento         DATE,
    sexo                    CHAR(1)       NOT NULL,
    peso_kg                 NUMERIC(6,2),
    cor_pelagem             VARCHAR(80),
    microchip               VARCHAR(50),
    ativo                   BOOLEAN       NOT NULL DEFAULT TRUE,
    data_cadastro           DATE          NOT NULL DEFAULT CURRENT_DATE,
    ultima_consulta         DATE,          -- atualizado via trigger
    CONSTRAINT fk_pet_cliente  FOREIGN KEY (cliente_id)
        REFERENCES clientes (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_pet_especie  FOREIGN KEY (especie_id)
        REFERENCES especies (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_pet_raca     FOREIGN KEY (raca_id)
        REFERENCES racas (id) ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT ck_pet_sexo     CHECK (sexo IN ('M', 'F')),
    CONSTRAINT ck_pet_peso     CHECK (peso_kg IS NULL OR peso_kg > 0),
    CONSTRAINT uq_pet_microchip UNIQUE (microchip)
);

-- =============================================================================
-- 6. TABELA: medicos
--    Médicos veterinários da clínica.
-- =============================================================================
CREATE TABLE medicos (
    id               SERIAL        PRIMARY KEY,
    especialidade_id INT           NOT NULL,
    nome             VARCHAR(150)  NOT NULL,
    crmv             VARCHAR(30)   NOT NULL,
    email            VARCHAR(200)  NOT NULL,
    telefone         VARCHAR(20),
    ativo            BOOLEAN       NOT NULL DEFAULT TRUE,
    data_admissao    DATE          NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_medico_especialidade FOREIGN KEY (especialidade_id)
        REFERENCES especialidades (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_medico_crmv  UNIQUE (crmv),
    CONSTRAINT uq_medico_email UNIQUE (email)
);

-- =============================================================================
-- 7. TABELA: servicos
--    Catálogo de serviços e procedimentos oferecidos pela clínica.
-- =============================================================================
CREATE TABLE servicos (
    id            SERIAL         PRIMARY KEY,
    nome          VARCHAR(150)   NOT NULL,
    descricao     TEXT,
    valor_base    NUMERIC(10,2)  NOT NULL,
    duracao_min   INT            NOT NULL DEFAULT 30, -- duração estimada em minutos
    ativo         BOOLEAN        NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_servico_nome  UNIQUE (nome),
    CONSTRAINT ck_servico_valor CHECK (valor_base >= 0),
    CONSTRAINT ck_servico_dur   CHECK (duracao_min > 0)
);

-- =============================================================================
-- 8. TABELA: consultas
--    Agendamentos e atendimentos realizados.
-- =============================================================================
CREATE TABLE consultas (
    id              SERIAL         PRIMARY KEY,
    pet_id          INT            NOT NULL,
    medico_id       INT            NOT NULL,
    servico_id      INT            NOT NULL,
    data_hora       TIMESTAMPTZ    NOT NULL,
    status          VARCHAR(20)    NOT NULL DEFAULT 'agendado',
    motivo          TEXT           NOT NULL,
    valor_cobrado   NUMERIC(10,2),
    desconto_pct    NUMERIC(5,2)   DEFAULT 0,
    forma_pagamento VARCHAR(50),
    data_pagamento  DATE,
    observacoes     TEXT,
    CONSTRAINT fk_consulta_pet     FOREIGN KEY (pet_id)
        REFERENCES pets (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_consulta_medico  FOREIGN KEY (medico_id)
        REFERENCES medicos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_consulta_servico FOREIGN KEY (servico_id)
        REFERENCES servicos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_consulta_status  CHECK (status IN (
        'agendado', 'em_atendimento', 'concluido', 'cancelado', 'nao_compareceu'
    )),
    CONSTRAINT ck_consulta_valor   CHECK (valor_cobrado IS NULL OR valor_cobrado >= 0),
    CONSTRAINT ck_consulta_desc    CHECK (desconto_pct >= 0 AND desconto_pct <= 100)
);

-- =============================================================================
-- 9. TABELA: prontuarios
--    Histórico clínico detalhado por consulta (1:1 com consultas concluídas).
-- =============================================================================
CREATE TABLE prontuarios (
    id                  SERIAL   PRIMARY KEY,
    consulta_id         INT      NOT NULL,
    anamnese            TEXT     NOT NULL,
    exame_fisico        TEXT,
    diagnostico         TEXT     NOT NULL,
    tratamento          TEXT,
    retorno_em          DATE,
    peso_aferido_kg     NUMERIC(6,2),
    temperatura_celsius NUMERIC(4,1),
    frequencia_cardiaca INT,      -- bpm
    frequencia_resp     INT,      -- mpm
    data_criacao        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    data_atualizacao    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_prontuario_consulta FOREIGN KEY (consulta_id)
        REFERENCES consultas (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT uq_prontuario_consulta UNIQUE (consulta_id),
    CONSTRAINT ck_pront_temp  CHECK (temperatura_celsius IS NULL OR (temperatura_celsius BETWEEN 30 AND 45)),
    CONSTRAINT ck_pront_peso  CHECK (peso_aferido_kg IS NULL OR peso_aferido_kg > 0),
    CONSTRAINT ck_pront_fc    CHECK (frequencia_cardiaca IS NULL OR frequencia_cardiaca > 0),
    CONSTRAINT ck_pront_fr    CHECK (frequencia_resp IS NULL OR frequencia_resp > 0)
);

-- =============================================================================
-- 10. TABELA: receitas
--     Prescrições médicas vinculadas ao prontuário.
--     Separadas do prontuário (um prontuário pode ter N medicamentos).
-- =============================================================================
CREATE TABLE receitas (
    id               SERIAL        PRIMARY KEY,
    prontuario_id    INT           NOT NULL,
    medicamento      VARCHAR(200)  NOT NULL,
    principio_ativo  VARCHAR(200),
    dose             VARCHAR(100)  NOT NULL,
    frequencia       VARCHAR(100)  NOT NULL,
    duracao_dias     INT,
    via_administracao VARCHAR(80)  NOT NULL DEFAULT 'oral',
    observacoes      TEXT,
    data_prescricao  DATE          NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_receita_prontuario FOREIGN KEY (prontuario_id)
        REFERENCES prontuarios (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT ck_receita_duracao CHECK (duracao_dias IS NULL OR duracao_dias > 0)
);

-- =============================================================================
-- 11. TABELA: vacinas
--     Controle de vacinação do pet por carteirinha.
-- =============================================================================
CREATE TABLE vacinas (
    id              SERIAL       PRIMARY KEY,
    pet_id          INT          NOT NULL,
    medico_id       INT          NOT NULL,
    nome_vacina     VARCHAR(150) NOT NULL,
    fabricante      VARCHAR(150),
    lote            VARCHAR(50),
    data_aplicacao  DATE         NOT NULL DEFAULT CURRENT_DATE,
    data_reforco    DATE,
    CONSTRAINT fk_vacina_pet    FOREIGN KEY (pet_id)
        REFERENCES pets (id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_vacina_medico FOREIGN KEY (medico_id)
        REFERENCES medicos (id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_vacina_reforco CHECK (data_reforco IS NULL OR data_reforco > data_aplicacao)
);

-- =============================================================================
-- ÍNDICES DE PERFORMANCE
-- =============================================================================
CREATE INDEX idx_pets_cliente        ON pets (cliente_id);
CREATE INDEX idx_pets_ult_consulta   ON pets (ultima_consulta DESC);
CREATE INDEX idx_consultas_pet       ON consultas (pet_id);
CREATE INDEX idx_consultas_medico    ON consultas (medico_id);
CREATE INDEX idx_consultas_data      ON consultas (data_hora DESC);
CREATE INDEX idx_consultas_status    ON consultas (status);
CREATE INDEX idx_prontuarios_cons    ON prontuarios (consulta_id);
CREATE INDEX idx_receitas_prontuario ON receitas (prontuario_id);
CREATE INDEX idx_vacinas_pet         ON vacinas (pet_id);
CREATE INDEX idx_vacinas_reforco     ON vacinas (data_reforco) WHERE data_reforco IS NOT NULL;
