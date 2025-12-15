const express = require("express");
const cors = require("cors"); // middleware de autenticação, se necessário
const rastreamentoRoutes = require("./routes/rastreamentoRoutes");
//const { startConsumer } = require('../consumidor');


const app = express();
const PORT = process.env.PORT || 50051;

// Middleware
app.use(cors()); // habilita CORS para permitir requisições do frontend
app.use(express.json()); // permite parsing de JSON no corpo das requisições
app.use("/rastreamento", rastreamentoRoutes);

// Inicia o servidor
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
  //startConsumer();
});