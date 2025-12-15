const express = require("express");
const cors = require("cors");
const authRoutes = require("./routes/authRoute");

const app = express();
const PORT = process.env.PORT || 50052;

app.use(cors()); // habilita CORS para permitir requisições do frontend
app.use(express.json()); // permite parsing de JSON no corpo das requisições
app.use("/auth", authRoutes)

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
  //startConsumer();
});