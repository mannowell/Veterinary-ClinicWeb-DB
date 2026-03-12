// server.js
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// Configuração do Banco
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'veterinaria',
    password: 'manno1234',
    port: 5432,
});

// Endpoint para o Gráfico de Faturamento (Consumindo sua View)
app.get('/api/faturamento', async (req, res) => {
    try {
        const result = await pool.query('SELECT mes_ano, receita_liquida FROM clinica.vw_faturamento_mensal_por_especialidade ORDER BY mes_referencia ASC');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).send('Erro no Servidor');
    }
});
// --- CONSULTAS (LISTAGEM) ---
app.get('/api/consultas', async (req, res) => {
    try {
        const { status } = req.query;
        let query = `
            SELECT 
                c.id, c.data_hora, c.status, c.motivo, c.observacoes,
                c.desconto_pct, c.valor_cobrado,
                p.nome as pet_nome, 
                cl.nome as tutor_nome, 
                m.nome as medico_nome, 
                s.nome as servico_nome,
                s.duracao_min,
                s.valor_base,
                COALESCE(c.valor_cobrado, (s.valor_base * (1 - COALESCE(c.desconto_pct, 0)/100.0))) as valor_calculado
            FROM clinica.consultas c
            JOIN clinica.pets p ON c.pet_id = p.id
            JOIN clinica.clientes cl ON p.cliente_id = cl.id
            JOIN clinica.medicos m ON c.medico_id = m.id
            JOIN clinica.servicos s ON c.servico_id = s.id
        `;
        const values = [];

        if (status && status !== 'todos') {
            query += ` WHERE c.status = $1`;
            values.push(status);
        }

        query += ` ORDER BY c.data_hora DESC`;

        const result = await pool.query(query, values);
        res.json(result.rows);
    } catch (err) {
        console.error('Erro ao buscar consultas:', err);
        res.status(500).json({ error: 'Erro interno do servidor' });
    }
});

// --- SUPORTE / CONFIGURAÇÃO (CRUD) ---
app.get('/api/medicos', async (req, res) => {
    try {
        const result = await pool.query('SELECT m.*, e.nome as especialidade_nome FROM clinica.medicos m JOIN clinica.especialidades e ON m.especialidade_id = e.id ORDER BY m.nome');
        res.json(result.rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/medicos', async (req, res) => {
    try {
        const { especialidade_id, nome, crmv, email, telefone } = req.body;
        const result = await pool.query(
            `INSERT INTO clinica.medicos (especialidade_id, nome, crmv, email, telefone) VALUES ($1, $2, $3, $4, $5) RETURNING *`,
            [especialidade_id, nome, crmv, email, telefone]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.put('/api/medicos/:id', async (req, res) => {
    try {
        const { nome, crmv, email, telefone, ativo } = req.body;
        const result = await pool.query(
            `UPDATE clinica.medicos SET nome=$1, crmv=$2, email=$3, telefone=$4, ativo=$5 WHERE id=$6 RETURNING *`,
            [nome, crmv, email, telefone, ativo, req.params.id]
        );
        res.json(result.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/servicos', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM clinica.servicos ORDER BY nome');
        res.json(result.rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/servicos', async (req, res) => {
    try {
        const { nome, descricao, valor_base, duracao_min } = req.body;
        const result = await pool.query(
            `INSERT INTO clinica.servicos (nome, descricao, valor_base, duracao_min) VALUES ($1, $2, $3, $4) RETURNING *`,
            [nome, descricao, valor_base, duracao_min]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.put('/api/servicos/:id', async (req, res) => {
    try {
        const { nome, descricao, valor_base, duracao_min, ativo } = req.body;
        const result = await pool.query(
            `UPDATE clinica.servicos SET nome=$1, descricao=$2, valor_base=$3, duracao_min=$4, ativo=$5 WHERE id=$6 RETURNING *`,
            [nome, descricao, valor_base, duracao_min, ativo, req.params.id]
        );
        res.json(result.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/especies', async (req, res) => {
    try {
        const result = await pool.query('SELECT id, nome FROM clinica.especies ORDER BY nome');
        res.json(result.rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/especialidades', async (req, res) => {
    try {
        const result = await pool.query('SELECT id, nome FROM clinica.especialidades ORDER BY nome');
        res.json(result.rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/racas', async (req, res) => {
    try {
        const { especie_id } = req.query;
        let query = 'SELECT id, nome, especie_id FROM clinica.racas';
        const params = [];
        if (especie_id) {
            query += ' WHERE especie_id = $1';
            params.push(especie_id);
        }
        query += ' ORDER BY nome';
        const result = await pool.query(query, params);
        res.json(result.rows);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

// Endpoint para Estatísticas do Dashboard
app.get('/api/stats', async (req, res) => {
    try {
        const stats = await pool.query(`
            SELECT 
                (SELECT COUNT(*) FROM clinica.pets) as total_pets,
                (SELECT COUNT(*) FROM clinica.clientes) as total_clientes,
                (SELECT COUNT(*) FROM clinica.consultas WHERE status = 'agendado') as total_agendados,
                (SELECT COUNT(*) FROM clinica.consultas WHERE data_hora::date = CURRENT_DATE) as consultas_hoje
        `);
        res.json(stats.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).send('Erro no Servidor');
    }
});

// Endpoint para Listagem de Pets
app.get('/api/pets', async (req, res) => {
    try {
        const result = await pool.query(`
            SELECT p.*, c.nome as tutor_nome, e.nome as especie_nome, r.nome as raca_nome
            FROM clinica.pets p
            JOIN clinica.clientes c ON p.cliente_id = c.id
            JOIN clinica.especies e ON p.especie_id = e.id
            LEFT JOIN clinica.racas r ON p.raca_id = r.id
            ORDER BY p.nome ASC
        `);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).send('Erro no Servidor');
    }
});

// Endpoint para Listagem de Clientes
app.get('/api/clientes', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM clinica.clientes ORDER BY nome ASC');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).send('Erro no Servidor');
    }
});

// --- CLIENTES CRUD ---
app.post('/api/clientes', async (req, res) => {
    try {
        let { nome, cpf, email, telefone, logradouro, numero, bairro, cidade, estado, cep } = req.body;
        
        // Normalização para o Banco (3NF strict constraints)
        cpf = cpf.replace(/\D/g, ''); // Apenas números
        if (estado) estado = estado.toUpperCase().trim();
        
        const result = await pool.query(
            `INSERT INTO clinica.clientes (nome, cpf, email, telefone, logradouro, numero, bairro, cidade, estado, cep) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
            [nome, cpf, email, telefone, logradouro, numero, bairro, cidade, estado, cep]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Erro ao inserir cliente:', err.message);
        res.status(500).json({ error: 'Erro de validação: Verifique se o CPF é único e o estado tem 2 letras (ex: SP).' });
    }
});

app.put('/api/clientes/:id', async (req, res) => {
    try {
        const { id } = req.params;
        let { nome, email, telefone, cidade, estado, ativo } = req.body;
        
        if (estado) estado = estado.toUpperCase().trim();

        const result = await pool.query(
            `UPDATE clinica.clientes SET nome=$1, email=$2, telefone=$3, cidade=$4, estado=$5, ativo=$6 WHERE id=$7 RETURNING *`,
            [nome, email, telefone, cidade, estado, ativo, id]
        );
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// --- PETS CRUD ---
app.post('/api/pets', async (req, res) => {
    try {
        const { cliente_id, especie_id, raca_id, nome, data_nascimento, sexo, peso_kg, cor_pelagem, microchip } = req.body;
        const result = await pool.query(
            `INSERT INTO clinica.pets (cliente_id, especie_id, raca_id, nome, data_nascimento, sexo, peso_kg, cor_pelagem, microchip) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
            [cliente_id, especie_id, raca_id, nome, data_nascimento, sexo, peso_kg, cor_pelagem, microchip]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/pets/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { nome, peso_kg, ativo } = req.body;
        const result = await pool.query(
            `UPDATE clinica.pets SET nome=$1, peso_kg=$2, ativo=$3 WHERE id=$4 RETURNING *`,
            [nome, peso_kg, ativo, id]
        );
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// --- CONSULTAS CRUD ---
app.post('/api/consultas', async (req, res) => {
    try {
        const { pet_id, medico_id, servico_id, data_hora, motivo, desconto_pct } = req.body;
        const result = await pool.query(
            `INSERT INTO clinica.consultas (pet_id, medico_id, servico_id, data_hora, status, motivo, desconto_pct) 
             VALUES ($1, $2, $3, $4, 'agendado', $5, $6) RETURNING *`,
            [pet_id, medico_id, servico_id, data_hora, motivo, desconto_pct || 0]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

app.put('/api/consultas/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { status, observacoes, desconto_pct } = req.body;
        
        let valor_cobrado = null;
        if (status === 'concluido') {
            const current = await pool.query(
                `SELECT s.valor_base FROM clinica.consultas c JOIN clinica.servicos s ON c.servico_id = s.id WHERE c.id = $1`, [id]
            );
            if (current.rows.length > 0) {
                const base = parseFloat(current.rows[0].valor_base);
                const desc = parseFloat(desconto_pct) || 0;
                valor_cobrado = base * (1 - desc/100);
            }
        }

        const result = await pool.query(
            `UPDATE clinica.consultas SET status=$1, observacoes=$2, desconto_pct=$3, valor_cobrado=COALESCE($4, valor_cobrado) 
             WHERE id=$5 RETURNING *`,
            [status, observacoes, desconto_pct || 0, valor_cobrado, id]
        );
        res.json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

// --- MÓDULO CLÍNICO (PRONTUÁRIOS, RECEITAS, VACINAS) ---

app.get('/api/consultas/:id/prontuario', async (req, res) => {
    const result = await pool.query('SELECT * FROM clinica.prontuarios WHERE consulta_id = $1', [req.params.id]);
    res.json(result.rows[0]);
});

app.post('/api/consultas/:id/prontuario', async (req, res) => {
    try {
        const { anamnese, exame_fisico, diagnostico, tratamento, retorno_em, peso_aferido_kg, temperatura_celsius, frequencia_cardiaca, frequencia_resp } = req.body;
        const result = await pool.query(
            `INSERT INTO clinica.prontuarios (consulta_id, anamnese, exame_fisico, diagnostico, tratamento, retorno_em, peso_aferido_kg, temperatura_celsius, frequencia_cardiaca, frequencia_resp) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING *`,
            [req.params.id, anamnese, exame_fisico, diagnostico, tratamento, retorno_em, peso_aferido_kg, temperatura_celsius, frequencia_cardiaca, frequencia_resp]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/prontuarios/:id/receitas', async (req, res) => {
    const result = await pool.query('SELECT * FROM clinica.receitas WHERE prontuario_id = $1', [req.params.id]);
    res.json(result.rows);
});

app.post('/api/prontuarios/:id/receitas', async (req, res) => {
    try {
        const { medicamento, principio_ativo, dose, frequencia, duracao_dias, via_administracao, observacoes } = req.body;
        const result = await pool.query(
            `INSERT INTO clinica.receitas (prontuario_id, medicamento, principio_ativo, dose, frequencia, duracao_dias, via_administracao, observacoes) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
            [req.params.id, medicamento, principio_ativo, dose, frequencia, duracao_dias, via_administracao, observacoes]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.get('/api/pets/:id/historico', async (req, res) => {
    try {
        const pet_id = req.params.id;
        const vacinas = await pool.query('SELECT * FROM clinica.vacinas WHERE pet_id = $1 ORDER BY data_aplicacao DESC', [pet_id]);
        const consultas = await pool.query(`
            SELECT c.*, s.nome as servico_nome, m.nome as medico_nome, pr.id as prontuario_id
            FROM clinica.consultas c
            JOIN clinica.servicos s ON c.servico_id = s.id
            JOIN clinica.medicos m ON c.medico_id = m.id
            LEFT JOIN clinica.prontuarios pr ON c.id = pr.consulta_id
            WHERE c.pet_id = $1 ORDER BY c.data_hora DESC`, [pet_id]);
        res.json({ vacinas: vacinas.rows, consultas: consultas.rows });
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.post('/api/pets/:id/vacinas', async (req, res) => {
    try {
        const { medico_id, nome_vacina, fabricante, lote, data_aplicacao, data_reforco } = req.body;
        const result = await pool.query(
            `INSERT INTO clinica.vacinas (pet_id, medico_id, nome_vacina, fabricante, lote, data_aplicacao, data_reforco) 
             VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [req.params.id, medico_id, nome_vacina, fabricante, lote, data_aplicacao, data_reforco]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) { res.status(500).json({ error: err.message }); }
});

app.listen(3000, () => console.log('API rodando na porta 3000'));