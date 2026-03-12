-- =============================================================================
-- VIEWS ADMINISTRATIVAS COMPLEXAS
-- Arquivo: views.sql
-- =============================================================================
SET search_path TO clinica;

-- =============================================================================
-- VIEW 1: vw_faturamento_mensal_por_especialidade
--
-- Objetivo: Controle financeiro mensal para a administração.
-- Mostra receita bruta, descontos concedidos, receita líquida e número de
-- atendimentos, agrupados por ano/mês e especialidade médica.
-- Inclui apenas consultas com status 'concluido' e pagamento registrado.
-- =============================================================================
CREATE OR REPLACE VIEW vw_faturamento_mensal_por_especialidade AS
SELECT
    DATE_TRUNC('month', c.data_hora)::DATE          AS mes_referencia,
    TO_CHAR(c.data_hora, 'MM/YYYY')                 AS mes_ano,
    e.nome                                           AS especialidade,
    COUNT(c.id)                                      AS total_consultas,
    COUNT(DISTINCT c.pet_id)                         AS pacientes_atendidos,
    COUNT(DISTINCT c.medico_id)                      AS medicos_ativos,
    -- Valor bruto (sem desconto)
    ROUND(
        SUM( srv.valor_base ), 2
    )                                                AS receita_bruta,
    -- Descontos concedidos
    ROUND(
        SUM( srv.valor_base * COALESCE(c.desconto_pct, 0) / 100 ), 2
    )                                                AS total_descontos,
    -- Receita líquida efetivamente cobrada
    ROUND( SUM( c.valor_cobrado ), 2 )               AS receita_liquida,
    -- Ticket médio por consulta
    ROUND( AVG( c.valor_cobrado ), 2 )               AS ticket_medio,
    -- Percentual de desconto médio
    ROUND( AVG( COALESCE(c.desconto_pct, 0) ), 2 )  AS desconto_medio_pct,
    -- Formas de pagamento (agregadas)
    STRING_AGG(
        DISTINCT c.forma_pagamento, ', '
        ORDER BY c.forma_pagamento
    )                                                AS formas_pagamento_utilizadas
FROM
    clinica.consultas  c
    INNER JOIN clinica.medicos     m   ON m.id = c.medico_id
    INNER JOIN clinica.especialidades e ON e.id = m.especialidade_id
    INNER JOIN clinica.servicos    srv ON srv.id = c.servico_id
WHERE
    c.status          = 'concluido'
    AND c.valor_cobrado IS NOT NULL
GROUP BY
    DATE_TRUNC('month', c.data_hora),
    TO_CHAR(c.data_hora, 'MM/YYYY'),
    e.nome
ORDER BY
    mes_referencia DESC,
    receita_liquida DESC;

COMMENT ON VIEW vw_faturamento_mensal_por_especialidade IS
'Faturamento mensal agrupado por especialidade: receita bruta, líquida, descontos, ticket médio e formas de pagamento.';

-- =============================================================================
-- VIEW 2: vw_historico_clinico_pet
--
-- Objetivo: Linha do tempo clínica completa de cada animal.
-- Consolida consultas, prontuários, receitas e vacinas num único relatório
-- cronológico por pet, para uso médico e administrativo.
-- =============================================================================
CREATE OR REPLACE VIEW vw_historico_clinico_pet AS
SELECT
    -- Identificação do paciente
    p.id                                             AS pet_id,
    p.nome                                           AS nome_pet,
    esp.nome                                         AS especie,
    COALESCE(r.nome, 'Sem raça definida')            AS raca,
    p.sexo,
    p.data_nascimento,
    CASE
        WHEN p.data_nascimento IS NOT NULL
        THEN EXTRACT(
            YEAR FROM AGE(CURRENT_DATE, p.data_nascimento)
        )::INT
        ELSE NULL
    END                                              AS idade_anos,
    p.microchip,
    p.ultima_consulta,

    -- Tutor
    cl.nome                                          AS nome_tutor,
    cl.cpf                                           AS cpf_tutor,
    cl.telefone                                      AS telefone_tutor,
    cl.email                                         AS email_tutor,

    -- Dados da consulta
    c.id                                             AS consulta_id,
    c.data_hora                                      AS data_consulta,
    c.status                                         AS status_consulta,
    c.motivo,
    srv.nome                                         AS servico_realizado,
    c.valor_cobrado,
    c.forma_pagamento,

    -- Médico responsável
    med.nome                                         AS medico_responsavel,
    med.crmv,
    e.nome                                           AS especialidade_medico,

    -- Prontuário (quando existir)
    pron.anamnese,
    pron.exame_fisico,
    pron.diagnostico,
    pron.tratamento,
    pron.peso_aferido_kg,
    pron.temperatura_celsius,
    pron.frequencia_cardiaca                         AS fc_bpm,
    pron.frequencia_resp                             AS fr_mpm,
    pron.retorno_em,

    -- Receitas prescritas (agregadas em JSON para preservar 3NF na view)
    (
        SELECT JSONB_AGG(
            JSONB_BUILD_OBJECT(
                'medicamento',      rec.medicamento,
                'principio_ativo',  rec.principio_ativo,
                'dose',             rec.dose,
                'frequencia',       rec.frequencia,
                'duracao_dias',     rec.duracao_dias,
                'via',              rec.via_administracao
            ) ORDER BY rec.id
        )
        FROM clinica.receitas rec
        WHERE rec.prontuario_id = pron.id
    )                                                AS receitas_prescritas,

    -- Vacinas aplicadas no pet (todas, independente da consulta)
    (
        SELECT JSONB_AGG(
            JSONB_BUILD_OBJECT(
                'vacina',       v.nome_vacina,
                'fabricante',   v.fabricante,
                'lote',         v.lote,
                'aplicacao',    v.data_aplicacao,
                'proximo_reforco', v.data_reforco
            ) ORDER BY v.data_aplicacao DESC
        )
        FROM clinica.vacinas v
        WHERE v.pet_id = p.id
    )                                                AS historico_vacinas

FROM
    clinica.pets          p
    INNER JOIN clinica.clientes       cl  ON cl.id  = p.cliente_id
    INNER JOIN clinica.especies       esp ON esp.id = p.especie_id
    LEFT  JOIN clinica.racas          r   ON r.id   = p.raca_id
    LEFT  JOIN clinica.consultas      c   ON c.pet_id = p.id
    LEFT  JOIN clinica.medicos        med ON med.id = c.medico_id
    LEFT  JOIN clinica.especialidades e   ON e.id   = med.especialidade_id
    LEFT  JOIN clinica.servicos       srv ON srv.id = c.servico_id
    LEFT  JOIN clinica.prontuarios    pron ON pron.consulta_id = c.id
WHERE
    p.ativo = TRUE
ORDER BY
    p.id,
    c.data_hora DESC;

COMMENT ON VIEW vw_historico_clinico_pet IS
'Histórico clínico completo por pet: dados do tutor, consultas, prontuário, receitas (JSON) e vacinas (JSON). Ordenado por pet e data mais recente.';

-- =============================================================================
-- VIEW 3 (BÔNUS): vw_vacinas_pendentes_reforco
-- Alerta de reforço de vacinas nos próximos 30 dias.
-- =============================================================================
CREATE OR REPLACE VIEW vw_vacinas_pendentes_reforco AS
SELECT
    p.nome                       AS nome_pet,
    esp.nome                     AS especie,
    cl.nome                      AS tutor,
    cl.telefone                  AS telefone_tutor,
    cl.email                     AS email_tutor,
    v.nome_vacina,
    v.data_aplicacao,
    v.data_reforco               AS data_reforco_prevista,
    v.data_reforco - CURRENT_DATE AS dias_para_reforco
FROM
    clinica.vacinas    v
    INNER JOIN clinica.pets      p   ON p.id  = v.pet_id
    INNER JOIN clinica.especies  esp ON esp.id = p.especie_id
    INNER JOIN clinica.clientes  cl  ON cl.id  = p.cliente_id
WHERE
    v.data_reforco IS NOT NULL
    AND v.data_reforco BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
    AND p.ativo = TRUE
ORDER BY
    v.data_reforco;

COMMENT ON VIEW vw_vacinas_pendentes_reforco IS
'Reforços de vacinas previstos para os próximos 30 dias, com dados do tutor para contato.';
