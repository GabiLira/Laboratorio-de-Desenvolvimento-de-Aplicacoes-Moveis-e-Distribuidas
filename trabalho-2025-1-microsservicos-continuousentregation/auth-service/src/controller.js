const db = require('../db');

async function cadastrarUsuario(nome, email, senha, tipo, timestamp) {
  await db.query(
    'INSERT INTO usuario (nome, email, senha, tipo, data_criacao) VALUES ($1, $2, $3, $4, $5)',
    [nome, email, senha, tipo, timestamp]
  );
}

async function logarUsuario(email, senha) {
  const res = await db.query(
    'SELECT * FROM usuario WHERE email = $1',
    [email]
  );
  console.log('Resultado da consulta de login:', res.rows);
  return res.rows[0];
}

module.exports = {
  cadastrarUsuario,
  logarUsuario
};