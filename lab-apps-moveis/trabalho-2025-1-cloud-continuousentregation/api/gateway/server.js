const express = require("express");
const cors = require("cors");
const axios = require("axios");
const swaggerUi = require("swagger-ui-express");
const YAML = require("yamljs");
const swaggerDocument = YAML.load("./swagger.yaml");

const app = express();
const PORT = process.env.PORT || 50092;

app.use(cors());
app.use(express.json());
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerDocument));

const amqp = require("amqplib");

async function publishMail({ to, subject, text }) {
  const rabbitUser = process.env.RABBIT_MQ_USERNAME;
  const rabbitPass = process.env.RABBIT_MQ_PASSWORD;
  const rabbitHost = "rabbitmq";
  const rabbitPort = 5672;

  const amqpUrl = `amqp://${rabbitUser}:${rabbitPass}@${rabbitHost}:${rabbitPort}`;
  const fila = "email";
  const connection = await amqp.connect(amqpUrl);
  const channel = await connection.createChannel();

  await channel.assertQueue(fila, { durable: true });

  const payload = { to, subject, text };
  channel.sendToQueue(fila, Buffer.from(JSON.stringify(payload)), {
    persistent: true,
  });

  console.log("📤 Mensagem publicada na fila de email:", fila, payload);

  await channel.close();
  await connection.close();
}

// Função publisher direto no gateway
async function publishNotificacao({ userId, mensagem }) {
  const rabbitUser = process.env.RABBIT_MQ_USERNAME;
  const rabbitPass = process.env.RABBIT_MQ_PASSWORD;
  const rabbitHost = "rabbitmq";
  const rabbitPort = 5672;

  const amqpUrl = `amqp://${rabbitUser}:${rabbitPass}@${rabbitHost}:${rabbitPort}`;
  const fila = "notificacoes";
  const connection = await amqp.connect(amqpUrl);
  const channel = await connection.createChannel();

  await channel.assertQueue(fila, { durable: true });

  const payload = { userId, mensagem };
  channel.sendToQueue(fila, Buffer.from(JSON.stringify(payload)), {
    persistent: true,
  });

  console.log("📤 Mensagem publicada na fila:", fila, payload);

  await channel.close();
  await connection.close();
}

//#region Rotas do Gateway - Rastreamento
// Redireciona POST /rastreamento/atualizar para o rastreamento-service
app.post("/rastreamento/criar", async (req, res) => {
  try {
    const response = await axios.post(
      "http://rastreamento-service:50051/rastreamento/criar",
      req.body
    );
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao atualizar localização" });
  }
});

//atualiazar localização
app.put("/rastreamento/atualizar", async (req, res) => {
  try {
    const response = await axios.put(
      "http://rastreamento-service:50051/rastreamento/atualizar",
      req.body
    );
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao atualizar localização" });
  }
});

// Redireciona GET /rastreamento/:pedidoId para o rastreamento-service
app.get("/rastreamento/:pedidoId", async (req, res) => {
  try {
    const response = await axios.get(
      `http://rastreamento-service:50051/rastreamento/${req.params.pedidoId}`
    );
    res.json(response.data);
  } catch (err) {
    if (err.response && err.response.status === 404) {
      res.status(404).json({ error: "Pedido não encontrado" });
    } else {
      res.status(500).json({ error: "Erro ao buscar localização" });
    }
  }
});

//#endregion

//#region Rotas do Gateway - Pedidos

app.post("/pedidos", async (req, res) => {
  try {
    const response = await axios.post(
      "http://pedido-service:50061/pedidos",
      req.body
    );
    res.status(201).json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao criar pedido " + err.message });
  }
});

app.get("/pedidos", async (req, res) => {
  try {
    const response = await axios.get("http://pedido-service:50061/pedidos");
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao listar pedido " + err.message });
  }
});

//get por id
app.get("/pedidos/:id", async (req, res) => {
  try {
    const response = await axios.get(
      `http://pedido-service:50061/pedidos/${req.params.id}`
    );
    if (response.data) {
      res.json(response.data);
    } else {
      res.status(404).json({ error: "Pedido não encontrado" });
    }
  } catch (err) {
    res.status(500).json({ error: "Erro ao buscar pedido " + err.message });
  }
});

app.put("/pedidos/:id", async (req, res) => {
  try {
    const response = await axios.put(
      `http://pedido-service:50061/pedidos/${req.params.id}`,
      req.body
    );

    await publishNotificacao({
      userId: response.data.id_usuario,
      mensagem: {
        title: "Pedido atualizado!",
        body: "Houve uma atualização no seu pedido.",
      },
    });

    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao atualizar pedido " + err.message });
  }
});

app.get("/pedidos/rotaentrega/:id", async (req, res) => {
  try {
    const response = await axios.get(
      `http://pedido-service:50061/pedidos/${req.params.id}`,
      req.body
    );

    await publishNotificacao({
      userId: response.data.id_usuario,
      mensagem: {
        title: "Pedido atualizado!",
        body: "O motorista iniciou a rota de entrega do seu pedido.",
      },
    });

    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao atualizar pedido " + err.message });
  }
});

//aceitar pedido
app.put("/pedidos/aceitar/:id", async (req, res) => {
  try {
    const response = await axios.put(
      `http://pedido-service:50061/pedidos/${req.params.id}`,
      req.body
    );

    await publishNotificacao({
      userId: response.data.id_usuario,
      mensagem: {
        title: "Pedido atualizado!",
        body: "A entrega do seu pedido foi aceita por um motorista!",
      },
    });

    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao atualizar pedido " + err.message });
  }
});

//finalizar pedido
app.put("/pedidos/finalizar/:id", async (req, res) => {
  try {
    const response = await axios.put(
      `http://pedido-service:50061/pedidos/${req.params.id}`,
      req.body
    );

    await publishNotificacao({
      userId: response.data.id_usuario,
      mensagem: {
        title: "Pedido finalizado!",
        body: `Seu pedido de ${response.data.nome} foi finalizado com sucesso. Avalie a entrega no app!`,
      },
    });

    const dataFormatada = formatarDataAgora();
    // Enviar email de confirmação
    await publishMail({
      to: response.data.usuario.email,
      subject: `Pedido ${response.data.nome} finalizado`,
      text: `Olá ${response.data.usuario.nome}! \nSeu pedido de ${response.data.nome} foi finalizado com sucesso no dia ${dataFormatada}. \nAcesse o app para avaliar a entrega!`,
    });

    await publishMail({
      to: response.data.motorista.email,
      subject: `Entrega de ${response.data.nome} finalizada`,
      text: `Olá ${response.data.motorista.nome}! \nVocê finalizou a entrega do pedido de ${response.data.nome} no dia ${dataFormatada}. \nAcesse o app para ver mais detalhes!`,
    });

    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao atualizar pedido " + err.message });
  }
});

app.delete("/pedidos/:id", async (req, res) => {
  try {
    const response = await axios.delete(
      `http://pedido-service:50061/pedidos/${req.params.id}`
    );
    res.json(response.data);

    await publishNotificacao({
      userId: response.data.id_usuario, // ajuste conforme o retorno do seu serviço
      mensagem: {
        title: "Pedido cancelado!",
        body: "Seu pedido foi cancelado.",
      },
    });
  } catch (err) {
    res.status(500).json({ error: "Erro ao cancelar pedido " + err.message });
  }
});

app.post("/pedidos/calcular-rota", async (req, res) => {
  try {
    const { origem, destino } = req.body;
    const response = await axios.post(
      "http://pedido-service:50061/pedidos/calcular-rota",
      { origem, destino }
    );
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao calcular rota " + err.message });
  }
});

//listar pedidos por situação e usuário
app.get("/pedidos/situacao/:situacao/usuario/:usuarioId", async (req, res) => {
  try {
    const { situacao, usuarioId } = req.params;
    const response = await axios.get(
      `http://pedido-service:50061/pedidos/situacao/${situacao}/usuario/${usuarioId}`
    );
    res.json(response.data);
  } catch (err) {
    res.status(500).json({
      error: "Erro ao listar pedidos por situação e usuário " + err.message,
    });
  }
});

//listar pedidos por situação
app.get("/pedidos/situacao/:situacao", async (req, res) => {
  try {
    const situacao = req.params.situacao;
    const response = await axios.get(
      `http://pedido-service:50061/pedidos/situacao/${situacao}`
    );
    res.json(response.data);
  } catch (err) {
    res
      .status(500)
      .json({ error: "Erro ao listar pedidos por situação " + err.message });
  }
});

//#endregion

//#region Rotas do Gateway - Auth
app.post("/auth/login", async (req, res) => {
  try {
    const response = await axios.post(
      "http://auth-service:50052/auth/login",
      req.body
    );
    res.json(response.data);
  } catch (err) {
    res.status(500).json({
      error: "Erro ao buscar informações de login",
      error: err.message,
    });
  }
});

app.post("/auth/register", async (req, res) => {
  try {
    const response = await axios.post(
      "http://auth-service:50052/auth/register",
      req.body
    );
    res.json(response.data);
  } catch (err) {
    res.status(500).json({
      error: "Erro ao buscar informações de registro",
      error: err.message,
    });
  }
});
//#endregion

//#region Rotas do Gateway - Promoções
app.put("/promocoes", async (req, res) => {
  try {
    const response = await axios.post(
      "http://promotion-service:50053/promocoes",
      req.body
    );
    res.status(201).json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao criar promoção " + err.message });
  }
});

app.get("/promocoes", async (req, res) => {
  try {
    const response = await axios.get(
      "http://promotion-service:50053/promotion"
    );
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao listar promoções " + err.message });
  }
});

app.post("/promocoes/enviar", async (req, res) => {
  publishNotificacao({
    userId: req.body.userId,
    mensagem: {
      title: "Nova promoção!",
      body: `${req.body.mensagem}`,
    },
  });
  res.status(200).json({ message: "Notificação enviada com sucesso!" });
});
//#enderegion

//#region Rotas do Gateway - Segmentação

//segmentação por cidade
app.post("/segmentacao/cidade", async (req, res) => {
  const { cidade } = req.body;
  if (!cidade) {
    return res
      .status(400)
      .json({ error: "Campo 'cidade' é obrigatório no body." });
  }
  try {
    const response = await axios.post(
      "http://segmentation-service:50054/segmentacao/cidade",
      { cidade }
    );

    publishNotificacao({
      userId: response.data,
      mensagem: {
        title: "Descontos em envio!",
        body: `Você de ${cidade} está recebendo descontos especiais em envios! Faça seu pedido agora!`,
      },
    });
    res.status(200).json({
      message: "Notificação enviada com sucesso! Segmentação cidade " + cidade,
    });
  } catch (err) {
    res
      .status(500)
      .json({ error: "Erro ao buscar segmentação por cidade " + err.message });
  }
});

function formatarDataAgora() {
  const agora = new Date();
  const dia = String(agora.getDate()).padStart(2, "0");
  const mes = String(agora.getMonth() + 1).padStart(2, "0");
  const ano = agora.getFullYear();
  const hora = String(agora.getHours()).padStart(2, "0");
  const minuto = String(agora.getMinutes()).padStart(2, "0");
  return `${dia}/${mes}/${ano} ${hora}:${minuto}`;
}

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
