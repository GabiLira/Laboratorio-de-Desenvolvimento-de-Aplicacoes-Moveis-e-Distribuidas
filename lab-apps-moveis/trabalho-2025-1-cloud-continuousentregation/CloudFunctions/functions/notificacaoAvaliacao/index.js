const axios = require("axios");

exports.notificacaoAvaliacao = async (req, res) => {
  try {
    const { clienteId, content, headings } = req.body;

    const idUsuario = clienteId;

    // Enviar push com OneSignal
    await axios.post("https://onesignal.com/api/v1/notifications", {
      app_id: "APP_ID",
      include_external_user_ids: [idUsuario],
      contents: { "en": content },
      headings: { "en": headings }
    }, {
      headers: {
        Authorization: "CHAVE_DE_API",
      }
    });

    res.status(200).send("Notificação enviada");
  } catch (e) {
    console.error(e);
    res.status(500).send("Erro ao enviar notificação");
  }
};
