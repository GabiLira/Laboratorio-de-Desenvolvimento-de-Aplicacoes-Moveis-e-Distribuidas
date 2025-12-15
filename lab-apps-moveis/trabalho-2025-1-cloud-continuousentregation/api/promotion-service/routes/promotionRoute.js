const express = require("express");
const router = express.Router();
const controller = require("../src/controller");

//Criar promoção
router.put("/", async (req, res) => {
  try {
    const idsString = await controller.listarUsuarios();
    const promocao = await controller.salvarPromocao(idsString);
    res.status(201).json(promocao);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Listar ids promoções
router.get("/", async (req, res) => {
  try {
    const ids = await controller.listarUsuarios();
    res.status(200).json({ids: ids});
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;