const express = require('express');
const app = express();

app.use(express.json());

app.get('/', (req, res) => {
  res.send('CryptoBot Webhook online!');
});

app.post('/webhook', (req, res) => {
  console.log('Recebi webhook:', req.body);

  // Aqui você processa a notificação do CryptoBot
  // Por exemplo, checar se o pagamento foi confirmado

  res.status(200).send('Webhook recebido com sucesso');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
