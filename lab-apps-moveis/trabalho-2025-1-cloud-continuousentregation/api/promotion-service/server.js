const express = require("express");
const cors = require("cors");
const promotionRoutes = require("./routes/promotionRoute");

const app = express();
const PORT = process.env.PORT || 50053;

app.use(cors()); // habilita CORS para permitir requisições do frontend
app.use(express.json()); // permite parsing de JSON no corpo das requisições
app.use("/promotion", promotionRoutes)

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});