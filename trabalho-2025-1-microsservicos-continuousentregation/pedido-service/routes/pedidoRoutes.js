const express = require("express");
const router = express.Router();
const controller = require("../src/controller");

// Criar pedido
router.post("/", async (req, res) => {
  try {
    const pedido = await controller.criarPedido(req.body);
    res.status(201).json(pedido);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Listar pedidos
router.get("/", async (req, res) => {
  try {
    const pedidos = await controller.listarPedidos();
    res.json(pedidos);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Atualizar pedido
router.put("/:id", async (req, res) => {
  try {
    const pedido = await controller.atualizarPedido(req.params.id, req.body);
    res.json(pedido);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Cancelar pedido
router.delete("/:id", async (req, res) => {
  try {
    const pedido = await controller.cancelarPedido(req.params.id);
    res.json(pedido);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Calcular rota
router.post("/calcular-rota", async (req, res) => {
  try {
    const { origem, destino } = req.body;
    const rota = await controller.calcularRota(origem, destino);
    res.json(rota);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
