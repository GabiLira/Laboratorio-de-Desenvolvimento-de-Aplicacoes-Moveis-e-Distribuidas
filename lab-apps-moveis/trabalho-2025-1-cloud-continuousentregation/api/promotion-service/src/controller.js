const db = require("../db");
const axios = require("axios");

async function salvarPromocao(idsString) {
    // idsString é uma string com ids separados por vírgula
    const res = await db.query(
        "UPDATE promocao set ids = $1",
        [idsString]
    );
    return res.rows[0];
}

async function listarUsuarios() {
    const res = await db.query("SELECT id FROM usuario");
    // Retorna uma string com os ids separados por vírgula
    return res.rows.map(row => String(row.id)).join(",");
}

module.exports = {
    salvarPromocao,
    listarUsuarios
};