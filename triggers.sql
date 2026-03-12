-- =============================================================================
-- TRIGGERS
-- Arquivo: triggers.sql
-- =============================================================================
SET search_path TO clinica;

-- =============================================================================
-- TRIGGER 1: Atualizar ultima_consulta do pet automaticamente
-- Acionado após INSERT ou UPDATE em consultas com status = 'concluido'.
-- Mantém o campo pets.ultima_consulta sempre sincronizado sem intervenção manual.
-- =============================================================================
CREATE OR REPLACE FUNCTION fn_atualizar_ultima_consulta()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    -- Atualiza somente quando a consulta é marcada como concluída
    IF NEW.status = 'concluido' THEN
        UPDATE clinica.pets
        SET    ultima_consulta = NEW.data_hora::DATE
        WHERE  id = NEW.pet_id
          AND  (ultima_consulta IS NULL OR ultima_consulta < NEW.data_hora::DATE);
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_atualizar_ultima_consulta
AFTER INSERT OR UPDATE OF status ON clinica.consultas
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_ultima_consulta();

COMMENT ON TRIGGER trg_atualizar_ultima_consulta ON clinica.consultas IS
'Atualiza pets.ultima_consulta quando uma consulta é concluída.';

-- =============================================================================
-- TRIGGER 2: Auditoria - bloquear exclusão de prontuários concluídos
-- Impede DELETE direto em prontuários vinculados a consultas concluídas,
-- garantindo conformidade com legislação de prontuários veterinários (CFMV).
-- =============================================================================
CREATE TABLE IF NOT EXISTS clinica.log_tentativas_exclusao (
    id          SERIAL      PRIMARY KEY,
    tabela      VARCHAR(50) NOT NULL,
    registro_id INT         NOT NULL,
    usuario     TEXT        NOT NULL DEFAULT current_user,
    tentativa   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    detalhe     TEXT
);

CREATE OR REPLACE FUNCTION fn_bloquear_exclusao_prontuario()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_status VARCHAR(20);
BEGIN
    SELECT c.status INTO v_status
    FROM   clinica.consultas c
    WHERE  c.id = OLD.consulta_id;

    IF v_status = 'concluido' THEN
        -- Registra a tentativa de exclusão ilegal
        INSERT INTO clinica.log_tentativas_exclusao (tabela, registro_id, detalhe)
        VALUES ('prontuarios', OLD.id,
                'Tentativa de exclusão de prontuário de consulta concluída pelo usuário: ' || current_user);

        RAISE EXCEPTION
            'Não é permitido excluir prontuários de consultas concluídas (id=%). '
            'Consulte o administrador do banco de dados.', OLD.id
            USING ERRCODE = '23000';
    END IF;
    RETURN OLD;
END;
$$;

CREATE TRIGGER trg_bloquear_exclusao_prontuario
BEFORE DELETE ON clinica.prontuarios
FOR EACH ROW
EXECUTE FUNCTION fn_bloquear_exclusao_prontuario();

COMMENT ON TRIGGER trg_bloquear_exclusao_prontuario ON clinica.prontuarios IS
'Bloqueia exclusão de prontuários de consultas já concluídas e registra a tentativa em log.';

-- =============================================================================
-- TRIGGER 3: Preencher automaticamente o valor_cobrado da consulta
-- Se o usuário não informar o valor, usa o valor_base do serviço aplicando desconto.
-- Fórmula: valor_cobrado = valor_base * (1 - desconto_pct / 100)
-- =============================================================================
CREATE OR REPLACE FUNCTION fn_calcular_valor_consulta()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
DECLARE
    v_valor_base NUMERIC(10,2);
BEGIN
    -- Só age quando o valor_cobrado não foi informado explicitamente
    IF NEW.valor_cobrado IS NULL THEN
        SELECT s.valor_base INTO v_valor_base
        FROM   clinica.servicos s
        WHERE  s.id = NEW.servico_id;

        NEW.valor_cobrado :=
            ROUND(v_valor_base * (1 - COALESCE(NEW.desconto_pct, 0) / 100), 2);
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_calcular_valor_consulta
BEFORE INSERT OR UPDATE OF servico_id, desconto_pct ON clinica.consultas
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_valor_consulta();

COMMENT ON TRIGGER trg_calcular_valor_consulta ON clinica.consultas IS
'Calcula valor_cobrado automaticamente a partir do valor_base do serviço e desconto informado.';

-- =============================================================================
-- TRIGGER 4 (BÔNUS): Atualizar data_atualizacao em prontuários automaticamente
-- =============================================================================
CREATE OR REPLACE FUNCTION fn_atualizar_timestamp_prontuario()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    NEW.data_atualizacao := NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_atualizar_timestamp_prontuario
BEFORE UPDATE ON clinica.prontuarios
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_timestamp_prontuario();
