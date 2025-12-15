const express = require("express");
const cors = require("cors");
const pedidoRoutes = require("./routes/pedidoRoutes");

const app = express();
const PORT = process.env.PORT || 50061;

app.use(cors());
app.use(express.json());
app.use("/pedidos", pedidoRoutes);

app.listen(PORT, () => {
  console.log(`Pedido-service rodando na porta ${PORT}`);
});
