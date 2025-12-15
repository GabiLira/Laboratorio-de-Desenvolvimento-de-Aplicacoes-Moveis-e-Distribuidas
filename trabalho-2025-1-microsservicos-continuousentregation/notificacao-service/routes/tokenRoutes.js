const express = require("express");
const router = express.Router();
const { db } = require("../../firebase");
// const { getFirestore } = require("firebase-admin/firestore");

// // Inicializa Firestore (caso não tenha feito ainda no firebase.js)
// const db = getFirestore();

/**
 * Endpoint para registrar token FCM vindo do frontend
 * Requisição POST: { userId: "cliente123", token: "abcdef..." }
 */
router.post("/registrar-token", async (req, res) => {
  const { userId, token } = req.body;

  if (!userId || !token) {
    return res.status(400).json({ erro: "Parâmetros obrigatórios ausentes" });
  }

  try {
    // Salva ou atualiza token do usuário
    await db.collection("tokens_fcm").doc(userId).set({ token }, { merge: true });
    return res.status(200).json({ sucesso: true });
  } catch (err) {
    console.error("Erro ao registrar token:", err);
    return res.status(500).json({ erro: "Erro interno ao registrar token" });
  }
});

/**
 * Endpoint GET para buscar o token FCM de um usuário
 */
router.get("/token/:userId", async (req, res) => {
  const userId = req.params.userId;

  try {
    const doc = await db.collection("tokens_fcm").doc(userId).get();
    if (!doc.exists) {
      return res.status(404).json({ erro: "Token não encontrado" });
    }
    return res.json(doc.data());
  } catch (err) {
    console.error("Erro ao buscar token:", err);
    return res.status(500).json({ erro: "Erro interno ao buscar token" });
  }
});

module.exports = router;