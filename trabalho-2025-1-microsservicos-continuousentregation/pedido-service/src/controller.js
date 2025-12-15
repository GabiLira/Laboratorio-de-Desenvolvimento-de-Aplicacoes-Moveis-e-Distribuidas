const db = require("../db");
const axios = require("axios");

// Cria um novo pedido
async function criarPedido({ nome, origem, destino, id_usuario }) {
  // origem e destino são objetos { lat, lng }
  const origemStr = `${origem.lat},${origem.lng}`;
  const destinoStr = `${destino.lat},${destino.lng}`;
  const res = await db.query(
    "INSERT INTO pedidos (nome, origem, destino, situacao, id_usuario) VALUES ($1, $2, $3, $4, $5) RETURNING *",
    [nome, origemStr, destinoStr, 1, id_usuario]
  );
  return res.rows[0];
}

// Lista todos os pedidos
async function listarPedidos() {
  const res = await db.query("SELECT * FROM pedidos");
  // Converte origem/destino string para objeto { lat, lng }
  return res.rows.map((pedido) => ({
    ...pedido,
    origem: strToCoord(pedido.origem),
    destino: strToCoord(pedido.destino),
  }));
}

// Atualiza um pedido
async function atualizarPedido(id, campos) {
  // Se origem/destino vierem como objeto, converte para string
  const camposAtualizados = { ...campos };
  if (
    camposAtualizados.origem &&
    typeof camposAtualizados.origem === "object"
  ) {
    camposAtualizados.origem = `${camposAtualizados.origem.lat},${camposAtualizados.origem.lng}`;
  }
  if (
    camposAtualizados.destino &&
    typeof camposAtualizados.destino === "object"
  ) {
    camposAtualizados.destino = `${camposAtualizados.destino.lat},${camposAtualizados.destino.lng}`;
  }
  const keys = Object.keys(camposAtualizados);
  const values = Object.values(camposAtualizados);
  const set = keys.map((k, i) => `${k} = $${i + 2}`).join(", ");
  const res = await db.query(
    `UPDATE pedidos SET ${set} WHERE id = $1 RETURNING *`,
    [id, ...values]
  );
  // Converte origem/destino para objeto
  const pedido = res.rows[0];
  if (pedido) {
    pedido.origem = strToCoord(pedido.origem);
    pedido.destino = strToCoord(pedido.destino);
  }
  return pedido;
}

// Cancela um pedido
async function cancelarPedido(id) {
  const res = await db.query(
    "UPDATE pedidos SET situacao = 0 WHERE id = $1 RETURNING *",
    [id]
  );
  // Converte origem/destino para objeto
  const pedido = res.rows[0];
  if (pedido) {
    pedido.origem = strToCoord(pedido.origem);
    pedido.destino = strToCoord(pedido.destino);
  }
  return pedido;
}

// Calcula rota usando OSRM
async function calcularRota(origem, destino) {
  // origem/destino: { lat, lng }
  const url = `http://router.project-osrm.org/route/v1/driving/${origem.lng},${origem.lat};${destino.lng},${destino.lat}?overview=full&geometries=geojson`;
  const res = await axios.get(url);
  return res.data;
}

// Função auxiliar para converter string "lat,lng" em objeto { lat, lng }
function strToCoord(str) {
  if (!str) return null;
  const [lat, lng] = str.split(",").map(Number);
  return { lat, lng };
}

module.exports = {
  criarPedido,
  listarPedidos,
  atualizarPedido,
  cancelarPedido,
  calcularRota,
};
