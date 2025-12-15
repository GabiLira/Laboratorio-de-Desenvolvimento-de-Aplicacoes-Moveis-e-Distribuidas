const admin = require("firebase-admin");
const serviceAccount = require("./firebase-admin-config.json"); // caminho para o JSON baixado

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

module.exports = { admin, db };