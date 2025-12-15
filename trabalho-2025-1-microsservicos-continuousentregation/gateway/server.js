const express = require("express");
const cors = require("cors");
const axios = require("axios");
const swaggerUi = require('swagger-ui-express');
const YAML = require('yamljs');
const swaggerDocument = YAML.load('./swagger.yaml');

const app = express();
const PORT = process.env.PORT || 50092;

app.use(cors());
app.use(express.json());
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

//#region Rotas do Gateway - Rastreamento
// Redireciona POST /rastreamento/atualizar para o rastreamento-service
app.post("/rastreamento/atualizar", async (req, res) => {
  try {
    const response = await axios.post(
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
    const response = await axios.post("http://pedido-service:50061/pedidos", req.body);
    res.status(201).json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao criar pedido" });
  }

})

app.get("/pedidos", async (req, res) => {
  try {
    const response = await axios.get("http://pedido-service:50061/pedidos");
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao listar pedidos" });
  }
})

app.put("/pedidos/:id", async (req, res) => {
  try {
    const response = await axios.put(`http://pedido-service:50061/pedidos/${req.params.id}`, req.body);
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao atualizar pedido" });
  }
})

app.delete("/pedidos/:id", async (req, res) => {
  try {
    const response = await axios.delete(`http://pedido-service:50061/pedidos/${req.params.id}`);
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao cancelar pedido" });
  }
})

app.post("/pedidos/calcular-rota", async (req, res) => {
  try {
    const { origem, destino } = req.body;
    const response = await axios.post("http://pedido-service:50061/pedidos/calcular-rota", { origem, destino });
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao calcular rota" });
  }
})

//#endregion

//#region Rotas do Gateway - Auth
app.post("/auth/login", async (req, res) => {
  try {
    const response = await axios.post("http://auth-service:50052/auth/login", req.body);
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao buscar informações de login" });
  }
});

app.post("/auth/register", async (req, res) => {
  try {
    const response = await axios.post("http://auth-service:50052/auth/register", req.body);
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: "Erro ao buscar informações de registro" });
  }
});
//#endregion

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});

