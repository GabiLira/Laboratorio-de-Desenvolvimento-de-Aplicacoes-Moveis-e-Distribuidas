const { admin } = require('../../firebase');

async function enviarNotificacaoPush(token, titulo, corpo, dadosExtras = {}) {
  const message = {
    token: token,
    notification: {
      title: titulo,
      body: corpo,
    },
    data: dadosExtras,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Notificação enviada com sucesso:", response);
  } catch (error) {
    console.error("Erro ao enviar notificação:", error);
  }
}

module.exports = { enviarNotificacaoPush };
