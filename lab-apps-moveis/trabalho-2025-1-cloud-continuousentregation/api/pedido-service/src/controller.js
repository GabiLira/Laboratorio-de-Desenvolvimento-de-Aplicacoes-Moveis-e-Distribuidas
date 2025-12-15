const db = require("../db");
const axios = require("axios");

// Cria um novo pedido
async function criarPedido({
  nome,
  origem,
  destino,
  id_usuario,
  origemNome,
  destinoNome,
}) {
  // origem e destino são objetos { lat, lng }
  const origemStr = `${origem.lat},${origem.lng}`;
  const destinoStr = `${destino.lat},${destino.lng}`;
  const res = await db.query(
    "INSERT INTO pedidos (nome, origem, destino, situacao, id_usuario, origemNome, destinoNome) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *",
    [nome, origemStr, destinoStr, 0, id_usuario, origemNome, destinoNome]
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

// Lista pedidos por situação e usuário
async function listarPedidosPorSituacaoEUsuario(situacao, usuarioId) {
  const res = await db.query(
    "SELECT * FROM pedidos WHERE situacao = $1 AND id_usuario = $2",
    [situacao, usuarioId]
  );
  // Converte origem/destino string para objeto { lat, lng }
  return res.rows.map((pedido) => ({
    ...pedido,
    origem: strToCoord(pedido.origem),
    destino: strToCoord(pedido.destino),
  }));
}

//lista por id
async function listarPedidoPorId(id) {
  const res = await db.query("SELECT * FROM pedidos WHERE id = $1", [id]);
  if (res.rows.length === 0) return null;
  const pedido = res.rows[0];
  // Converte origem/destino string para objeto { lat, lng }
  pedido.origem = strToCoord(pedido.origem);
  pedido.destino = strToCoord(pedido.destino);
  return pedido;
}

// Lista pedidos por situação e usuário
async function listarPedidosPorSituacao(situacao) {
  const res = await db.query("SELECT * FROM pedidos WHERE situacao = $1", [
    situacao,
  ]);
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

  // Atualiza o pedido
  await db.query(`UPDATE pedidos SET ${set} WHERE id = $1`, [id, ...values]);

  // Busca o pedido atualizado junto com os dados do usuário
  const res = await db.query(
    `SELECT p.*, 
            u.id as usuario_id, u.nome as usuario_nome, u.email as usuario_email, u.tipo as usuario_tipo, u.data_criacao as usuario_data_criacao,
            m.id as motorista_id, m.nome as motorista_nome, m.email as motorista_email, m.tipo as motorista_tipo, m.data_criacao as motorista_data_criacao
       FROM pedidos p
       JOIN usuario u ON p.id_usuario = u.id
       LEFT JOIN usuario m ON p.id_motorista = m.id
      WHERE p.id = $1`,
    [id]
  );
  const pedido = res.rows[0];
  if (!pedido) return null;

  // Converte origem/destino para objeto
  pedido.origem = strToCoord(pedido.origem);
  pedido.destino = strToCoord(pedido.destino);

  // Retorna o pedido junto com os dados do usuário e do motorista (se houver)
  return {
    ...pedido,
    usuario: {
      id: pedido.usuario_id,
      nome: pedido.usuario_nome,
      email: pedido.usuario_email,
      tipo: pedido.usuario_tipo,
      data_criacao: pedido.usuario_data_criacao,
    },
    motorista: pedido.motorista_id
      ? {
          id: pedido.motorista_id,
          nome: pedido.motorista_nome,
          email: pedido.motorista_email,
          tipo: pedido.motorista_tipo,
          data_criacao: pedido.motorista_data_criacao,
        }
      : null,
  };
}

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
  listarPedidoPorId,
  listarPedidosPorSituacaoEUsuario,
  listarPedidosPorSituacao,
  atualizarPedido,
  cancelarPedido,
  calcularRota,
};
