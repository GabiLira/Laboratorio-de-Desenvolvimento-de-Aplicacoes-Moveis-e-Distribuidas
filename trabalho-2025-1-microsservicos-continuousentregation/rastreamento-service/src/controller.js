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

module.exports = {
  salvarLocalizacao,
  obterUltimaLocalizacao,
};
