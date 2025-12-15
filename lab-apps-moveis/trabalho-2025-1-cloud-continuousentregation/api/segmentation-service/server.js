const express = require("express");
const cors = require("cors");
const segmentationRoute = require("./routes/segmentationRoute");

const app = express();
const PORT = process.env.PORT || 50054;

app.use(cors()); // habilita CORS para permitir requisições do frontend
app.use(express.json()); // permite parsing de JSON no corpo das requisições
app.use("/segmentacao", segmentationRoute)

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});