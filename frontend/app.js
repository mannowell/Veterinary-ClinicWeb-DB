document.addEventListener('DOMContentLoaded', () => {
    const tableBody = document.getElementById('table-body');
    const filterBtns = document.querySelectorAll('.filter-btn');
    const modal = document.getElementById('details-modal');
    const closeModalBtn = document.getElementById('close-modal');
    
    let currentStatusFilter = '';
    let consultasData = [];

    const formatDate = (dateString) => {
        const options = { 
            day: '2-digit', month: '2-digit', year: 'numeric',
            hour: '2-digit', minute: '2-digit'
        };
        return new Date(dateString).toLocaleDateString('pt-BR', options);
    };

    const getStatusBadge = (status) => {
        const normalized = (status || 'agendado').toLowerCase();
        return `<span class="status-badge status-${normalized}">${status.charAt(0).toUpperCase() + status.slice(1)}</span>`;
    };

    const fetchConsultas = async () => {
        tableBody.innerHTML = '<tr><td colspan="7" class="loading">Carregando consultas...</td></tr>';
        try {
            const url = currentStatusFilter 
                ? `http://localhost:3000/api/consultas?status=${currentStatusFilter}`
                : 'http://localhost:3000/api/consultas';
            const response = await fetch(url);
            consultasData = await response.json();
            renderTable(consultasData);
        } catch (error) {
            console.error('Erro:', error);
            tableBody.innerHTML = '<tr><td colspan="7" class="loading" style="color: var(--status-cancelado)">Erro ao carregar dados.</td></tr>';
        }
    };

    const btnNovo = document.getElementById('btn-novo-agendamento');
    const consultaModal = document.getElementById('consulta-modal');
    const consultaForm = document.getElementById('consulta-form');
    const closeConsBtn = document.getElementById('close-consulta-modal');

    const renderTable = (data) => {
        if (data.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="7" class="loading">Nenhuma consulta encontrada.</td></tr>';
            return;
        }

        tableBody.innerHTML = data.map(consulta => `
            <tr data-id="${consulta.id}">
                <td>${formatDate(consulta.data_hora)}</td>
                <td><strong>${consulta.pet_nome}</strong> <span style="color: var(--text-secondary); font-size: 0.85rem;">(${consulta.tutor_nome})</span></td>
                <td>Dr(a). ${consulta.medico_nome}</td>
                <td>${consulta.servico_nome}</td>
                <td>${getStatusBadge(consulta.status)}</td>
                <td style="font-family: monospace; font-weight: bold; color: var(--accent-light);">R$ ${parseFloat(consulta.valor_calculado).toLocaleString('pt-BR', { minimumFractionDigits: 2 })}</td>
                <td>
                    <div class="action-buttons">
                        <button class="action-icon btn-view-cons" data-id="${consulta.id}" title="Detalhes">👁</button>
                        <button class="action-icon btn-edit-cons" data-id="${consulta.id}" title="Editar">✎</button>
                        <button class="action-icon btn-prontuario" data-id="${consulta.id}" title="Prontuário/Clínico">📋</button>
                    </div>
                </td>
            </tr>
        `).join('');

        document.querySelectorAll('.btn-view-cons').forEach(btn => btn.onclick = (e) => openModal(e.target.dataset.id));
        document.querySelectorAll('.btn-edit-cons').forEach(btn => btn.onclick = (e) => openEditModal(e.target.dataset.id));
        document.querySelectorAll('.btn-prontuario').forEach(btn => btn.onclick = (e) => openProntuario(e.target.dataset.id));
    };

    let currentServicos = [];
    const prefetchOptions = async () => {
        try {
            const [petsRes, medRes, servRes] = await Promise.all([
                fetch('http://localhost:3000/api/pets'),
                fetch('http://localhost:3000/api/medicos'), 
                fetch('http://localhost:3000/api/servicos')
            ]);
            const pets = await petsRes.json();
            const medicos = await medRes.json();
            currentServicos = await servRes.json();

            document.getElementById('cons-pet').innerHTML = pets.map(p => `<option value="${p.id}">${p.nome} (${p.tutor_nome})</option>`).join('');
            document.getElementById('cons-medico').innerHTML = medicos.map(m => `<option value="${m.id}">${m.nome}</option>`).join('');
            document.getElementById('cons-servico').innerHTML = '<option value="">Selecione...</option>' + currentServicos.map(s => `<option value="${s.id}">${s.nome} (R$ ${s.valor_base})</option>`).join('');
        } catch (err) { console.error('Prefetch error:', err); }
    };

    const updateValorPreview = () => {
        const servId = document.getElementById('cons-servico').value;
        const serv = currentServicos.find(s => s.id == servId);
        if (!serv) {
            document.getElementById('cons-valor-preview').textContent = 'R$ 0,00';
            document.getElementById('cons-valor-preview-novo').textContent = 'R$ 0,00';
            return;
        }

        const isEdit = document.getElementById('consulta-id').value !== '';
        const descInput = isEdit ? document.getElementById('cons-desconto') : document.getElementById('cons-desconto-novo');
        const previewDiv = isEdit ? document.getElementById('cons-valor-preview') : document.getElementById('cons-valor-preview-novo');
        
        const desc = parseFloat(descInput.value) || 0;
        const valor = serv.valor_base * (1 - desc/100);
        previewDiv.textContent = `R$ ${valor.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`;
    };

    document.getElementById('cons-servico').addEventListener('change', updateValorPreview);
    document.getElementById('cons-desconto').addEventListener('input', updateValorPreview);
    document.getElementById('cons-desconto-novo').addEventListener('input', updateValorPreview);

    filterBtns.forEach(btn => {
        btn.onclick = () => {
            filterBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            currentStatusFilter = btn.dataset.status;
            fetchConsultas();
        };
    });

    btnNovo.onclick = () => {
        consultaForm.reset();
        document.getElementById('consulta-id').value = '';
        document.getElementById('consulta-modal-title').textContent = 'Novo Agendamento';
        document.getElementById('cons-edit-fields').style.display = 'none';
        document.getElementById('cons-new-discount').style.display = 'block';
        document.getElementById('cons-pet').disabled = false;
        document.getElementById('cons-medico').disabled = false;
        document.getElementById('cons-servico').disabled = false;
        consultaModal.classList.add('active');
        prefetchOptions();
    };

    const openEditModal = (id) => {
        const c = consultasData.find(x => x.id == id);
        if (!c) return;
        consultaForm.reset();
        document.getElementById('consulta-id').value = c.id;
        document.getElementById('consulta-modal-title').textContent = 'Editar Agendamento';
        document.getElementById('cons-edit-fields').style.display = 'block';
        document.getElementById('cons-new-discount').style.display = 'none';
        document.getElementById('cons-status').value = c.status;
        document.getElementById('cons-obs').value = c.observacoes || '';
        document.getElementById('cons-desconto').value = c.desconto_pct || 0;
        document.getElementById('cons-data').value = c.data_hora.substring(0, 16);
        document.getElementById('cons-motivo').value = c.motivo;
        
        consultaModal.classList.add('active');
        prefetchOptions().then(() => {
            document.getElementById('cons-pet').value = c.pet_id || '';
            document.getElementById('cons-medico').value = c.medico_id || '';
            document.getElementById('cons-servico').value = currentServicos.find(s => s.nome === c.servico_nome)?.id || '';
            updateValorPreview();
        });
    };

    closeConsBtn.onclick = () => consultaModal.classList.remove('active');

    consultaForm.onsubmit = async (e) => {
        e.preventDefault();
        const id = document.getElementById('consulta-id').value;
        const method = id ? 'PUT' : 'POST';
        const url = id ? `http://localhost:3000/api/consultas/${id}` : 'http://localhost:3000/api/consultas';

        const isEdit = id !== '';
        const desc = parseFloat(isEdit ? document.getElementById('cons-desconto').value : document.getElementById('cons-desconto-novo').value) || 0;

        const payload = {
            pet_id: parseInt(document.getElementById('cons-pet').value),
            medico_id: parseInt(document.getElementById('cons-medico').value),
            servico_id: parseInt(document.getElementById('cons-servico').value),
            data_hora: document.getElementById('cons-data').value,
            motivo: document.getElementById('cons-motivo').value,
            desconto_pct: desc,
            status: isEdit ? document.getElementById('cons-status').value : 'agendado',
            observacoes: isEdit ? document.getElementById('cons-obs').value : ''
        };

        try {
            await fetch(url, {
                method,
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
            consultaModal.classList.remove('active');
            fetchConsultas();
        } catch (error) { alert('Falha ao salvar'); }
    };

    const openModal = (id) => {
        const c = consultasData.find(x => x.id == id);
        if (!c) return;
        document.getElementById('modal-status').innerHTML = getStatusBadge(c.status);
        document.getElementById('modal-data').textContent = formatDate(c.data_hora);
        document.getElementById('modal-pet').textContent = c.pet_nome;
        document.getElementById('modal-tutor').textContent = c.tutor_nome;
        document.getElementById('modal-medico').textContent = `Dr(a). ${c.medico_nome}`;
        document.getElementById('modal-servico').textContent = c.servico_nome;
        document.getElementById('modal-motivo').textContent = c.motivo;
        
        const valorBase = parseFloat(c.valor_base) || 0;
        const descPct = parseFloat(c.desconto_pct) || 0;
        const valorTotal = parseFloat(c.valor_calculado) || 0;

        document.getElementById('modal-valor-base').textContent = `R$ ${valorBase.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`;
        document.getElementById('modal-desconto').textContent = `${descPct}% (R$ ${(valorBase * descPct / 100).toLocaleString('pt-BR', { minimumFractionDigits: 2 })})`;
        document.getElementById('modal-valor-total').textContent = `R$ ${valorTotal.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}`;

        modal.classList.add('active');
    };

    closeModalBtn.onclick = () => modal.classList.remove('active');

    // --- PRONTUÁRIO ---
    const pronModal = document.getElementById('prontuario-modal');
    const recModal = document.getElementById('receita-modal');
    const recForm = document.getElementById('receita-form');
    let activeConsultaId = null;
    let tempReceitas = [];

    const openProntuario = async (id) => {
        activeConsultaId = id;
        const c = consultasData.find(x => x.id == id);
        document.getElementById('pron-pet-name').textContent = `Paciente: ${c.pet_nome}`;
        document.getElementById('pron-anamnese').value = '';
        document.getElementById('pron-exame').value = '';
        document.getElementById('pron-diagnostico').value = '';
        tempReceitas = [];
        renderReceitasList();

        try {
            const res = await fetch(`http://localhost:3000/api/consultas/${id}/prontuario`);
            if (res.ok) {
                const data = await res.json();
                if (data) {
                    document.getElementById('pron-anamnese').value = data.anamnese || '';
                    document.getElementById('pron-exame').value = data.exame_fisico || '';
                    document.getElementById('pron-diagnostico').value = data.diagnostico || '';
                    document.getElementById('pron-peso').value = data.peso_aferido_kg || '';
                    document.getElementById('pron-temp').value = data.temperatura_celsius || '';
                }
            }
        } catch(e) {}
        pronModal.classList.add('active');
    };

    document.getElementById('close-prontuario-modal').onclick = () => pronModal.classList.remove('active');
    document.getElementById('btn-add-receita').onclick = () => recModal.classList.add('active');
    document.getElementById('close-receita-modal').onclick = () => recModal.classList.remove('active');

    recForm.onsubmit = (e) => {
        e.preventDefault();
        tempReceitas.push({
            medicamento: document.getElementById('rec-medicamento').value,
            dose: document.getElementById('rec-dose').value,
            frequencia: document.getElementById('rec-freq').value,
            observacoes: document.getElementById('rec-obs').value
        });
        recForm.reset();
        recModal.classList.remove('active');
        renderReceitasList();
    };

    const renderReceitasList = () => {
        document.getElementById('receitas-list').innerHTML = tempReceitas.map((r, i) => `
            <div style="background: rgba(255,255,255,0.05); padding: 0.5rem; margin-bottom: 0.5rem; border-radius: 4px; display: flex; justify-content: space-between;">
                <div><strong>${r.medicamento}</strong> - ${r.dose} (${r.frequencia})</div>
                <button onclick="window.removeReceita(${i})" style="background: none; border: none; color: #ff4d4d; cursor: pointer;">&times;</button>
            </div>
        `).join('');
    };
    window.removeReceita = (i) => { tempReceitas.splice(i, 1); renderReceitasList(); };

    document.getElementById('btn-save-prontuario').onclick = async () => {
        const payload = {
            anamnese: document.getElementById('pron-anamnese').value,
            exame_fisico: document.getElementById('pron-exame').value,
            diagnostico: document.getElementById('pron-diagnostico').value,
            peso_aferido_kg: parseFloat(document.getElementById('pron-peso').value),
            temperatura_celsius: parseFloat(document.getElementById('pron-temp').value)
        };
        try {
            const res = await fetch(`http://localhost:3000/api/consultas/${activeConsultaId}/prontuario`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            });
            const pront = await res.json();
            for (const rec of tempReceitas) {
                await fetch(`http://localhost:3000/api/prontuarios/${pront.id}/receitas`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(rec)
                });
            }
            alert('Atendimento salvo!');
            pronModal.classList.remove('active');
            fetchConsultas();
        } catch (err) { alert('Erro ao salvar'); }
    };

    // URL Parameter handling for Dashboard redirection
    const urlParams = new URL(window.location.href).searchParams;
    const initialFilter = urlParams.get('filter');
    if (initialFilter) {
        if (initialFilter === 'hoje') {
            // We'll filter by date 'today' if we had a date filter, 
            // but for now let's map 'hoje' to showing all if we don't have a specific 'hoje' status
            // or we can implement a custom date filter in fetchConsultas
            currentStatusFilter = ''; 
        } else {
            currentStatusFilter = initialFilter;
        }
        
        filterBtns.forEach(btn => {
            if (btn.dataset.status === currentStatusFilter) btn.classList.add('active');
            else btn.classList.remove('active');
        });
    }

    fetchConsultas();
});
