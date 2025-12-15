const express = require("express");
const router = express.Router();
const amqp = require("amqplib");
const authenticateToken = require("../../middleware/auth"); // middleware de autenticação, se necessário

router.post("/enviar-notificacao", authenticateToken, async (req, res) => {
  const { userId, mensagem, fila } = req.body;

  if (!userId || !mensagem || !mensagem.title || !mensagem.body) {
    return res.status(400).json({ erro: "Dados incompletos." });
  }

  try {
    const conn = await amqp.connect("amqp://localhost");
    const ch = await conn.createChannel();

    await ch.assertQueue(fila, { durable: true });

    const payload = { userId, mensagem };
    ch.sendToQueue(fila, Buffer.from(JSON.stringify(payload)));

    console.log("Notificação enviada para a fila:", payload);

    setTimeout(() => conn.close(), 500);

    res.json({ sucesso: true, enviadoParaFila: payload });
  } catch (erro) {
    console.error("Erro ao enviar para a fila:", erro);
    res.status(500).json({ erro: "Falha ao enviar notificação" });
  }
});

module.exports = router;
