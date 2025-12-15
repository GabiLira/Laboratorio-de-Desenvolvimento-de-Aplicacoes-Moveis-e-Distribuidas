const db = require("../db");
const axios = require("axios");

async function enviarSegmentacaoCidade(cidade) {
    // Busca todos os id_usuario dos pedidos onde origemnome é parecido com a cidade
    const res = await db.query(
        "SELECT DISTINCT id_usuario FROM pedidos WHERE origemnome ILIKE $1",
        [`%${cidade}%`]
    );
    // Retorna um array de ids
    return res.rows.map(row => String(row.id_usuario)).join(",");
}

module.exports = {
    enviarSegmentacaoCidade
};