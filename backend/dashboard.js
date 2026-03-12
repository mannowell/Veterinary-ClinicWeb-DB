// dashboard.js
async function drawRevenueChart() {
    const canvas = document.getElementById('revenueChart');
    const ctx = canvas.getContext('2d');
    
    // 1. Buscar dados da API
    const response = await fetch('http://localhost:3000/api/faturamento');
    const data = await response.json();

    const margin = 40;
    const width = canvas.width - margin * 2;
    const height = canvas.height - margin * 2;
    const maxVal = Math.max(...data.map(d => parseFloat(d.receita_liquida)));

    // Limpar
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // 2. Desenhar Eixos
    ctx.strokeStyle = 'rgba(255,255,255,0.2)';
    ctx.beginPath();
    ctx.moveTo(margin, margin);
    ctx.lineTo(margin, height + margin);
    ctx.lineTo(width + margin, height + margin);
    ctx.stroke();

    // 3. Desenhar Linha de Dados
    ctx.strokeStyle = '#00f2ad'; // Verde Neon
    ctx.lineWidth = 3;
    ctx.shadowBlur = 10;
    ctx.shadowColor = '#00f2ad';
    ctx.beginPath();

    data.forEach((point, i) => {
        const x = margin + (i * (width / (data.length - 1)));
        const y = (height + margin) - (parseFloat(point.receita_liquida) / maxVal * height);
        
        if (i === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
        
        // Desenhar Ponto
        ctx.fillStyle = '#fff';
        ctx.arc(x, y, 2, 0, Math.PI * 2);
    });

    ctx.stroke();
}

drawRevenueChart();