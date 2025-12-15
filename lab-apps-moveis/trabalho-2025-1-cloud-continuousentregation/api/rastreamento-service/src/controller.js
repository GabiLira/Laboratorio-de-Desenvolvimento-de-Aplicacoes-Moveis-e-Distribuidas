const db = require('../db');

async function salvarLocalizacao(pedidoId, latitude, longitude, timestamp) {
  await db.query(
    'INSERT INTO rastreamento (id_pedido, latitude, longitude, timestamp) VALUES ($1, $2, $3, $4)',
    [pedidoId, latitude, longitude, timestamp]
  );
}

async function obterUltimaLocalizacao(pedidoId) {
  const res = await db.query(
    'SELECT latitude, longitude, timestamp FROM rastreamento WHERE id_pedido = $1 ORDER BY timestamp DESC LIMIT 1',
    [pedidoId]
  );
  return res.rows[0];
}

// Atualizar localização
async function atualizarLocalizacao(pedidoId, latitude, longitude, timestamp) {
  const res = await db.query(
    'UPDATE rastreamento SET latitude = $1, longitude = $2, timestamp = $3 WHERE id_pedido = $4',
    [latitude, longitude, timestamp, pedidoId]
  );
  if (res.rowCount === 0) {
    throw new Error('Pedido não encontrado ou localização não atualizada');
  }
  return res.rowCount;
}

module.exports = {
  salvarLocalizacao,
  obterUltimaLocalizacao,
  atualizarLocalizacao,
};
