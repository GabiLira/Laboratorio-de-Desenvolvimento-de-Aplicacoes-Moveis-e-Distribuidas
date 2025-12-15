const express = require("express");
const router = express.Router();
const controller = require("../src/controller");

//Criar segmentação por cidade
router.post("/cidade", async (req, res) => {
  const { cidade } = req.body;
  if (!cidade) {
    return res.status(400).json({ error: "Campo 'cidade' é obrigatório no body." });
  }
  try {
    const ids = await controller.enviarSegmentacaoCidade(cidade);
    res.status(201).json(ids);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


module.exports = router;