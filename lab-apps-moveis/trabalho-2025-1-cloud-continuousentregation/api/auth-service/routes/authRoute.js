const express = require('express');
const router = express.Router();

const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const controller = require("../src/controller");

const { signToken } = require('../auth');


router.post('/register', async (req, res) => {
  const { nome, email, senha, tipo } = req.body;

  if (!nome || !email || !senha || !tipo)
    return res.status(400).json({ message: 'Nome, email, senha e tipo são obrigatórios.' });

  try {
    const senhaHash = await bcrypt.hash(senha, 10);

    const timestamp = new Date().toISOString();

    await controller.cadastrarUsuario(nome, email, senhaHash, tipo, timestamp);

    res.status(201).json({ message: 'Usuário registrado com sucesso.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Erro interno no servidor.', error: err.message });
  }
});

router.post('/login', async (req, res) => {
  const { email, senha } = req.body;

  if (!email || !senha)
    return res.status(400).json({ message: 'Email e senha são obrigatórios.' });

  try {
    const usuario = await controller.logarUsuario(email, senha);
    console.log('Usuário encontrado:', usuario);
    const senhaCorreta = await bcrypt.compare(senha, usuario.senha);

    if (!senhaCorreta)
      return res.status(401).json({ message: 'Senha incorreta.' });

    const payload = { email: usuario.email, id: usuario.id };
    console.log('Payload do token:', payload);
    const token = signToken(payload);
    console.log('Token gerado:', token);

    res.status(200).json({
      message: 'Login bem-sucedido!',
      token,
      usuario: { id: usuario.id, email: usuario.email, tipo: usuario.tipo }
    });
  } catch (err) {
    console.error('Erro no login:', err);
    res.status(500).json({ message: 'Erro interno no servidor.', error: err.message });
  }
});

module.exports = router;
