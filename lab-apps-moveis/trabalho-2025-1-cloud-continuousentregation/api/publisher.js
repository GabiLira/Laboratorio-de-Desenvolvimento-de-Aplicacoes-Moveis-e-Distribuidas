const amqp = require("amqplib");
const { use } = require("react");

async function publishNotificacao({ userId, mensagem }) {
  const amqpUrl = process.env.RABBITMQ_URL || "amqp://localhost";
  const fila = "notificacoes";
  const connection = await amqp.connect(amqpUrl);
  const channel = await connection.createChannel();

  await channel.assertQueue(fila, { durable: true });

  const payload = { userId, mensagem };
  channel.sendToQueue(fila, Buffer.from(JSON.stringify(payload)), { persistent: true });

  console.log("📤 Mensagem publicada na fila:", fila, payload);

  await channel.close();
  await connection.close();
}

if (require.main === module) {
  // Troque os valores abaixo para testar
  publishNotificacao({
    userId: userId,
    mensagem: {
      title: mensagem.title || "Avaliação de Entrega",
      body: mensagem.body || "Por favor, avalie a entrega que você recebeu.",
    }
  });
}

module.exports = { publishNotificacao };