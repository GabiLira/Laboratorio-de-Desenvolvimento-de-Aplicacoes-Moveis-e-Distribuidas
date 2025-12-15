const amqp = require("amqplib");
const axios = require("axios");

console.log("Consumidor iniciado");

async function enviarNotificacaoOneSignalViaCloudFunctions(externalId, title, body) {
  try {
    await axios.post(
      "https://us-central1-entregation.cloudfunctions.net/notificacaoAvaliacao",
      { clienteId: externalId,
        content: body,
        headings: title,
      },
      {headers: {'Content-Type': 'application/json'}}
    );
    console.log("✅ Notificação enviada via Cloud Functions para OneSignal");
  } catch (err) {
    console.error("❌ Erro ao enviar via Cloud Functions para OneSignal:", err.response?.data || err.message);
  }
}

async function enviarEmailViaCloudFunctions(to, subject, text) {
  try {
    await axios.post(
      "https://us-central1-entregation.cloudfunctions.net/sendEmail",
      { to, subject, text },
      { headers: { 'Content-Type': 'application/json' } }
    );
    console.log("✅ Email enviado via Cloud Functions");
  } catch (err) {
    console.error("❌ Erro ao enviar email via Cloud Functions:", err.response?.data || err.message);
  }
}

async function startConsumer() {
  const rabbitUser = process.env.RABBIT_MQ_USERNAME;
  const rabbitPass = process.env.RABBIT_MQ_PASSWORD;
  const rabbitHost = 'rabbitmq';
  const rabbitPort = 5672;

  const amqpUrl = `amqp://${rabbitUser}:${rabbitPass}@${rabbitHost}:${rabbitPort}`;

  const connection = await amqp.connect(amqpUrl);
  const channel = await connection.createChannel();
  const fila = "notificacoes";

  await channel.assertQueue(fila, { durable: true });

  console.log("📥 Aguardando mensagens na fila:", fila);

  channel.consume(fila, async (msg) => {
    if (!msg) return;

    try {
      const { userId, mensagem } = JSON.parse(msg.content.toString());

      if (!userId || !mensagem?.title || !mensagem?.body) {
        console.warn("⚠️ Mensagem malformada:", msg.content.toString());
        channel.ack(msg);
        return;
      }

      await enviarNotificacaoOneSignalViaCloudFunctions(userId, mensagem.title, mensagem.body);

      console.log(`✅ Notificação enviada para ${userId}`);
    } catch (erro) {
      console.error("❌ Erro ao processar mensagem:", erro);
    }

    channel.ack(msg);
  });
}

async function startEmailConsumer() {

  const rabbitUser = process.env.RABBIT_MQ_USERNAME;
  const rabbitPass = process.env.RABBIT_MQ_PASSWORD;
  const rabbitHost = 'rabbitmq';
  const rabbitPort = 5672;

  const amqpUrl = `amqp://${rabbitUser}:${rabbitPass}@${rabbitHost}:${rabbitPort}`;

  const connection = await amqp.connect(amqpUrl);
  const channel = await connection.createChannel();
  const fila = "email";

  await channel.assertQueue(fila, { durable: true });

  console.log("📥 Aguardando mensagens na fila de email:", fila);

  channel.consume(fila, async (msg) => {
    if (!msg) return;

    try {
      const { to, subject, text } = JSON.parse(msg.content.toString());

      if (!to || !subject || !text) {
        console.warn("⚠️ Mensagem de email malformada:", msg.content.toString());
        channel.ack(msg);
        return;
      }

      await enviarEmailViaCloudFunctions(to, subject, text);

      console.log(`✅ Email enviado para ${email}`);
    } catch (erro) {
      console.error("❌ Erro ao processar mensagem de email:", erro);
    }

    channel.ack(msg);
  });

}

module.exports = { startConsumer };

startConsumer();
startEmailConsumer();