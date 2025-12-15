const express = require("express");
const router = express.Router();
const controller = require("../src/controller");

// Rota para atualizar localização (POST /rastreamento/atualizar)
router.post("/criar", async (req, res) => {
  const { id_pedido, latitude, longitude, timestamp } = req.body;
  try {
    await controller.salvarLocalizacao(id_pedido, latitude, longitude, timestamp);
    res.json({ status: "Localização atualizada com sucesso" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

//atualizar localização (PUT /rastreamento/atualizar)
router.put("/atualizar", async (req, res) => {
  const { pedidoId, latitude, longitude, timestamp } = req.body;
  try {
    await controller.atualizarLocalizacao(pedidoId, latitude, longitude, timestamp);
    res.json({ status: "Localização atualizada com sucesso" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Rota para obter localização atual (GET /rastreamento/:pedidoId)
router.get("/:pedidoId", async (req, res) => {
  const { pedidoId } = req.params;
  try {
    const localizacao = await controller.obterUltimaLocalizacao(pedidoId);
    if (!localizacao) {
      return res.status(404).json({ error: "Pedido não encontrado" });
    }
    res.json(localizacao);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;