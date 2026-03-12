-- =============================================================================
-- DADOS DE SEED (EXEMPLO / DEMONSTRAÇÃO)
-- Arquivo: seeds.sql
-- =============================================================================
SET search_path TO clinica;

-- =============================================================================
-- Especialidades
-- =============================================================================
INSERT INTO especialidades (nome, descricao) VALUES
    ('Clínica Geral',       'Atendimento clínico geral para todas as espécies'),
    ('Dermatologia',        'Diagnóstico e tratamento de doenças de pele em animais'),
    ('Ortopedia',           'Tratamento de ossos, articulações e musculatura'),
    ('Oftalmologia',        'Diagnóstico e cirurgia ocular veterinária'),
    ('Oncologia',           'Diagnóstico e tratamento de neoplasias em animais'),
    ('Cardiologia',         'Avaliação e tratamento de doenças cardíacas'),
    ('Neurologia',          'Diagnóstico de doenças do sistema nervoso');

-- =============================================================================
-- Espécies e Raças
-- =============================================================================
INSERT INTO especies (nome) VALUES
    ('Canino'), ('Felino'), ('Ave'), ('Réptil'), ('Roedor');

INSERT INTO racas (especie_id, nome) VALUES
    (1, 'Labrador Retriever'),
    (1, 'Bulldog Francês'),
    (1, 'Golden Retriever'),
    (1, 'Poodle'),
    (1, 'SRD'),
    (2, 'Maine Coon'),
    (2, 'Persa'),
    (2, 'Siamês'),
    (2, 'SRD'),
    (3, 'Calopsita'),
    (3, 'Periquito'),
    (4, 'Iguana'),
    (5, 'Hamster Sírio');

-- =============================================================================
-- Serviços
-- =============================================================================
INSERT INTO servicos (nome, descricao, valor_base, duracao_min) VALUES
    ('Consulta Clínica Geral',  'Avaliação geral de saúde do animal',               120.00, 30),
    ('Consulta Especializada',  'Consulta com médico especialista',                  200.00, 45),
    ('Eletrocardiograma',       'ECG veterinário com laudo',                         250.00, 40),
    ('Ultrassonografia',        'Ultrassom abdominal ou específico',                 300.00, 30),
    ('Hemograma Completo',      'Exame laboratorial de sangue completo',              90.00, 10),
    ('Cirurgia de Castração',   'Orquiectomia ou OSH eletiva',                      700.00, 90),
    ('Vacinação',               'Aplicação de vacina + certificado',                  80.00, 15),
    ('Raio-X',                  'Radiografia de região específica',                  150.00, 20),
    ('Microchipagem',           'Implante de microchip com cadastro no SINID',        60.00, 10),
    ('Retorno',                 'Consulta de retorno sem custo adicional',              0.00, 20);

-- =============================================================================
-- Clientes (Tutores)
-- =============================================================================
INSERT INTO clientes (nome, cpf, email, telefone, logradouro, numero, bairro, cidade, estado, cep) VALUES
    ('Ana Beatriz Ferreira',    '12345678901', 'ana.ferreira@email.com',    '11987651001', 'Rua das Palmeiras',    '123', 'Jardins',        'São Paulo',       'SP', '01401000'),
    ('Carlos Eduardo Souza',    '23456789012', 'carlos.souza@email.com',    '11987652002', 'Av. Paulista',         '900', 'Bela Vista',     'São Paulo',       'SP', '01310100'),
    ('Fernanda Lima Costa',     '34567890123', 'fernanda.costa@email.com',  '21987653003', 'Rua do Catete',        '55',  'Catete',         'Rio de Janeiro',  'RJ', '22220000'),
    ('Roberto Alves Nunes',     '45678901234', 'roberto.nunes@email.com',   '31987654004', 'Av. do Contorno',      '400', 'Savassi',        'Belo Horizonte',  'MG', '30110010'),
    ('Juliana Mendes Prado',    '56789012345', 'juliana.prado@email.com',   '41987655005', 'Rua XV de Novembro',   '200', 'Centro',         'Curitiba',        'PR', '80020310');

-- =============================================================================
-- Médicos
-- =============================================================================
INSERT INTO medicos (especialidade_id, nome, crmv, email, telefone) VALUES
    (1, 'Dr. Pedro Augusto Rocha',  'SP-12345', 'pedro.rocha@clinica.com',    '11912340001'),
    (1, 'Dra. Mariana Oliveira',    'SP-23456', 'mariana.oliveira@clinica.com','11912340002'),
    (2, 'Dr. Rafael Silveira',      'SP-34567', 'rafael.silveira@clinica.com', '11912340003'),
    (3, 'Dra. Amanda Torres',       'RJ-45678', 'amanda.torres@clinica.com',   '21912340004'),
    (6, 'Dr. Lucas Figueiredo',     'MG-56789', 'lucas.figueiredo@clinica.com','31912340005');

-- =============================================================================
-- Pets
-- =============================================================================
INSERT INTO pets (cliente_id, especie_id, raca_id, nome, data_nascimento, sexo, peso_kg, cor_pelagem, microchip) VALUES
    (1, 1, 1,   'Thor',     '2019-05-10', 'M', 32.5, 'Amarelo',         'BR001234567890'),
    (1, 2, 6,   'Mimi',     '2020-08-22', 'F',  5.2, 'Cinza e branco',  'BR002345678901'),
    (2, 1, 4,   'Bob',      '2018-03-14', 'M',  9.8, 'Branco',          'BR003456789012'),
    (3, 1, 5,   'Luna',     '2021-01-30', 'F', 18.3, 'Caramelo',        'BR004567890123'),
    (4, 2, 9,   'Nala',     '2022-06-05', 'F',  4.1, 'Laranja',         'BR005678901234'),
    (5, 3, 10,  'Pingo',    '2020-09-15', 'M',  0.09,'Amarelo e cinza', NULL),
    (2, 1, 3,   'Simba',    '2017-11-20', 'M', 28.7, 'Dourado',         'BR007890123456');

-- =============================================================================
-- Consultas (mix de status para demonstrar relatórios)
-- =============================================================================
INSERT INTO consultas (pet_id, medico_id, servico_id, data_hora, status, motivo, desconto_pct, forma_pagamento, data_pagamento) VALUES
    -- Thor - concluídas
    (1, 1, 1, '2025-01-15 09:00:00-03', 'concluido', 'Consulta de rotina anual',           0,  'cartao_credito', '2025-01-15'),
    (1, 3, 1, '2025-03-20 14:00:00-03', 'concluido', 'Coceira excessiva na pele',          10, 'pix',            '2025-03-20'),
    (1, 1, 1, '2025-06-10 10:00:00-03', 'concluido', 'Vômito e diarreia há 2 dias',        0,  'dinheiro',       '2025-06-10'),
    -- Mimi
    (2, 2, 1, '2025-02-05 11:00:00-03', 'concluido', 'Primeira consulta – avaliação geral', 0, 'pix',            '2025-02-05'),
    (2, 2, 7, '2025-04-10 15:00:00-03', 'concluido', 'Vacinação antirrábica e V4',          0, 'cartao_debito',  '2025-04-10'),
    -- Bob
    (3, 5, 3, '2025-05-08 08:30:00-03', 'concluido', 'Avaliação cardiológica – sopro',      5, 'cartao_credito', '2025-05-08'),
    (3, 1, 1, '2025-08-12 16:00:00-03', 'concluido', 'Revisão pós-tratamento cardíaco',    15, 'pix',            '2025-08-12'),
    -- Luna
    (4, 4, 1, '2025-07-01 09:00:00-03', 'concluido', 'Claudicação no membro posterior',     0, 'pix',            '2025-07-01'),
    (4, 4, 8, '2025-07-01 09:30:00-03', 'concluido', 'Raio-X de quadril',                   0, 'pix',            '2025-07-01'),
    -- Nala
    (5, 2, 1, '2025-09-03 13:00:00-03', 'concluido', 'Perda de peso e apatia',              0, 'cartao_credito', '2025-09-03'),
    -- Pingo
    (6, 1, 1, '2025-10-14 10:00:00-03', 'concluido', 'Avaliação geral – ave nova',          0, 'dinheiro',       '2025-10-14'),
    -- Simba
    (7, 3, 2, '2025-11-20 14:30:00-03', 'concluido', 'Dermatite crônica – acompanhamento',  0, 'pix',            '2025-11-20'),
    -- Agendadas futuras
    (1, 1, 10,'2026-04-05 09:00:00-03', 'agendado',  'Retorno pós-consulta dermatológica',  0, NULL, NULL),
    (3, 5,  3,'2026-04-10 08:00:00-03', 'agendado',  'Reavaliação cardiológica 6 meses',    0, NULL, NULL);

-- =============================================================================
-- Prontuários (para cada consulta concluída)
-- =============================================================================
INSERT INTO prontuarios (consulta_id, anamnese, exame_fisico, diagnostico, tratamento, retorno_em, peso_aferido_kg, temperatura_celsius, frequencia_cardiaca, frequencia_resp) VALUES
    (1,  'Animal sem queixas. Tutora relata bom apetite e disposição. Vacinação em dia.',
         'Animal alerta, hidratado, mucosas normocoradas, sem alterações auscultatórias.',
         'Animal hígido – consulta de rotina.', 'Sem medicações. Manter dieta e exercícios regulares. Repetir hemograma em 12 meses.', '2026-01-15', 32.5, 38.8, 88, 24),
    (2,  'Tutor relata prurido generalizado há 3 semanas, piora noturna. Sem mudança de dieta.', 
         'Lesões eritematosas e alopécicas em abdômen. Teste de raspagem positivo.', 
         'Dermatite alérgica atópica moderada.',
         'Apoquel 16mg 1x/dia por 30 dias. Shampoo hipoalergênico 2x/semana.', '2025-04-20', 31.9, 38.5, 90, 22),
    (3,  'Vômito 4x em 24h e fezes amolecidas. Animal apático. Comeu "algo na rua" segundo tutor.',
         'Desidratação leve (6%). Dor à palpação abdominal. Temperatura elevada.',
         'Gastroenterite aguda com desidratação leve.',
         'Soro glicosado EV 500ml. Ondasetrona 0,5mg/kg EV. Dieta hídrica 24h, depois pastosa 48h.', '2025-06-17', 30.8, 39.4, 95, 26),
    (4,  'Primeira consulta. Tutora adotou o animal como filhote. Sem histórico médico prévio.',
         'Filhote ativo, bem nutrido. Mucosas rosadas. Ausência de ectoparasitas.',
         'Avaliação de saúde geral – filhote saudável.',
         'Iniciar protocolo vacinal (V4). Vermifugar com Drontal 1cp. Retornar em 21 dias.', '2025-02-26', 4.8, 38.2, 180, 30),
    (5,  'Retorno para vacinação conforme protocolo. Animal sem queixas.',
         'Animal ativo e saudável. Sem reações à vacina anterior.',
         'Aplicação de antirrábica + V4 dose de reforço.',
         'Vacinas aplicadas. Observar por 30 minutos. Retornar em 12 meses.', '2026-04-10', 5.0, 38.1, 185, 28),
    (6,  'Tutor refere sopro cardíaco detectado em consulta anterior. Animal com cansaço fácil.',
         'Sopro sistólico grau III/VI em foco mitral. Mucosas levemente cianóticas.',
         'Doença Valvular Mitral – Estágio B2 (ACVIM).',
         'Pimobendan 5mg 2x/dia. Enalapril 5mg 1x/dia. Restrição de exercícios intensos. ECG mensal.', '2025-06-08', 9.5, 38.0, 145, 32),
    (7,  'Retorno cardiológico. Tutor refere boa resposta ao tratamento, menos cansaço.',
         'Sopro presente porém estável grau II-III. Mucosas normocoradas.',
         'DVm B2 – estável com medicação.',
         'Manter Pimobendan e Enalapril. Solicitar ecocardiograma. Retornar em 3 meses.', '2025-11-12', 9.3, 37.9, 138, 28),
    (8,  'Claudicação progressiva em membro posterior direito há 1 semana. Dor ao apoio.',
         'Dor intensa à palpação de quadril direito. Score de dor 4/5.',
         'Displasia coxofemoral – suspeita radiográfica.',
         'Meloxicam 0,1mg/kg 1x/dia por 10 dias. Repouso absoluto. Aguardar laudo de RX.', '2025-07-15', 18.0, 38.6, 92, 22),
    (9,  'Exame complementar ao diagnóstico de displasia.',
         'Radiografia realizada em decúbito dorsal e lateral.',
         'Displasia coxofemoral bilateral grau moderado.',
         'Confirmado diagnóstico. Encaminhar para avaliação cirúrgica ortopédica.', '2025-07-15', NULL, NULL, NULL, NULL),
    (10, 'Animal com perda de peso de 1,2kg em 2 meses. Apetite reduzido. Polidipsia.',
         'Animal apático, desidratação leve. Poliúria evidenciada.',
         'Suspeita de doença renal crônica – aguardar exames laboratoriais (hemograma + urinálise).', 
         'Hidratação oral. Dieta renal úmida. Solicitar painel renal completo. Retornar em 7 dias.', '2025-09-10', 3.8, 38.3, 190, 32),
    (11, 'Ave adotada recentemente. Tutora relata alimentação mista (sementes e frutas).',
         'Plumagem em bom estado. Sem secreção nasal. Peso adequado para a espécie.',
         'Ave saudável. Orientações nutricionais necessárias.',
         'Transição para ração extrusada balanceada. Suprimento de vitamina A. Retornar em 6 meses.', '2026-04-14', 0.089, 38.5, 320, 60),
    (12, 'Paciente com histórico de dermatite crônica. Tutor relata melhora parcial com tratamento anterior.',
         'Lesões residuais em região cervical e dorsal. Escoriações por prurido.',
         'Dermatite alérgica crônica em fase de controle.',
         'Ciclosporina 5mg/kg 1x/dia por 60 dias. Banho com clorexidina 2x/semana. Reavaliar.', '2026-01-20', 28.2, 38.4, 78, 20);

-- =============================================================================
-- Receitas
-- =============================================================================
INSERT INTO receitas (prontuario_id, medicamento, principio_ativo, dose, frequencia, duracao_dias, via_administracao, observacoes) VALUES
    (2,  'Apoquel',       'Oclacitinib',    '1 comprimido 16mg', '1x ao dia',   30, 'oral', 'Administrar com alimento para evitar náuseas'),
    (3,  'Ondasetrona',   'Ondasetrona',    '0,5mg/kg',          'dose única EV', 1, 'intravenosa', 'Aplicado em consultório'),
    (3,  'Soro Glicosado','Glicose 5%',     '500mL',             'infusão contínua 6h', 1, 'intravenosa', 'Monitorar hidratação'),
    (4,  'Drontal Plus',  'Praziquantel+Pamoato de Pirantel+Febantel', '1 comprimido', 'dose única', 1, 'oral', 'Repetir após 15 dias'),
    (6,  'Vetmedin',      'Pimobendan',     '5mg',               '2x ao dia',   365, 'oral', 'Administrar 1h antes das refeições'),
    (6,  'Enalapril',     'Maleato de Enalapril','5mg',           '1x ao dia',   365, 'oral', 'Monitorar pressão arterial mensalmente'),
    (7,  'Vetmedin',      'Pimobendan',     '5mg',               '2x ao dia',   90,  'oral', 'Manter posologia. Não interromper sem orientação.'),
    (7,  'Enalapril',     'Maleato de Enalapril','5mg',           '1x ao dia',   90,  'oral', 'Manter posologia.'),
    (8,  'Meloxicam',     'Meloxicam',      '0,1mg/kg',          '1x ao dia',   10,  'oral', 'Nunca administrar com estômago vazio'),
    (10, 'Royal Canin Renal', 'Dieta terapêutica', 'ad libitum',  'livre',       NULL,'oral', 'Transição gradual em 7 dias'),
    (12, 'Atopica',       'Ciclosporina',   '25mg',              '1x ao dia',   60,  'oral', 'Proteger da luz solar. Refrigerar após abertura.');

-- =============================================================================
-- Vacinas
-- =============================================================================
INSERT INTO vacinas (pet_id, medico_id, nome_vacina, fabricante, lote, data_aplicacao, data_reforco) VALUES
    (1, 1, 'V10',             'Fort Dodge',   'FD2024001', '2024-01-15', '2025-01-15'),
    (1, 1, 'Antirrábica',     'Merial',       'MR2024002', '2024-01-15', '2025-01-15'),
    (2, 2, 'V4',              'Ourofino',     'OF2025001', '2025-02-05', '2026-02-05'),
    (2, 2, 'Antirrábica',     'Merial',       'MR2025003', '2025-04-10', '2026-04-10'),
    (3, 5, 'V8',              'Fort Dodge',   'FD2025010', '2025-01-20', '2026-01-20'),
    (3, 5, 'Antirrábica',     'Merial',       'MR2025011', '2025-01-20', '2026-01-20'),
    (4, 4, 'V8',              'Zoetis',       'ZT2025020', '2025-03-10', '2026-03-10'),
    (5, 2, 'V4',              'Ourofino',     'OF2025030', '2024-12-15', '2025-12-15'),
    (7, 3, 'V10',             'Fort Dodge',   'FD2025040', '2025-09-01', '2026-09-01'),
    (7, 3, 'Antirrábica',     'Merial',       'MR2025041', '2025-09-01', '2026-09-01');
