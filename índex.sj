const TelegramBot = require('node-telegram-bot-api');
const axios = require('axios');

// Configurações — substitua pelos seus dados
const TOKEN = 'Whoainz_bot:8050991119:AAHbxYTplpfEPVlYhMKJLXrq46B4J0oKrYI'.split(':')[1];
const APP_ID = 416539;  // Seu CryptoBot App ID
const CRYPTOBOT_TOKEN = 'AAoXpsgTmKb1zgW8irAQb2pjW0JrZx8FXuP'; // CryptoBot token

// Canais para venda — mapeie plano e ID do canal
const channels = {
  vip: '-1002626370198',          // Vip/conteúdos full💠VIP Content
  pride: '-1002739308190',        // PrideZ⚡OOpride
};

const bot = new TelegramBot(TOKEN, { polling: true });

bot.onText(/\/start/, (msg) => {
  const chatId = msg.chat.id;
  bot.sendMessage(chatId, 'Bem-vindo! Use /buy para assinar o canal VIP.', {
    reply_markup: {
      inline_keyboard: [
        [{ text: 'Comprar Plano VIP', callback_data: 'buy_vip' }],
        [{ text: 'Comprar Plano Pride', callback_data: 'buy_pride' }],
      ]
    }
  });
});

// Quando usuário clicar no botão
bot.on('callback_query', async (callbackQuery) => {
  const msg = callbackQuery.message;
  const chatId = msg.chat.id;
  const data = callbackQuery.data;

  if (data.startsWith('buy_')) {
    const plano = data.split('_')[1];
    const canalId = channels[plano];
    if (!canalId) {
      bot.sendMessage(chatId, 'Plano inválido.');
      return;
    }

    // Cria invoice no CryptoBot (exemplo simples, adapte conforme docs do CryptoBot)
    try {
      const invoiceResponse = await axios.post(`https://api.cryptobot.org/v1/apps/${APP_ID}/invoices`, {
        amount: 10,  // valor fixo para teste, você pode mudar ou parametrizar
        currency: 'BRL', // moeda
        callback_url: `https://SEU_SERVIDOR/webhook`, // webhook para confirmar pagamento (você precisa implementar)
        success_url: `https://t.me/${bot.username}?start=success`,
        // Outros parâmetros que o CryptoBot pedir
      }, {
        headers: {
          'Authorization': `Bearer ${CRYPTOBOT_TOKEN}`,
          'Content-Type': 'application/json'
        }
      });

      const invoice = invoiceResponse.data.invoice;
      // Envie o link do invoice para o usuário pagar
      bot.sendMessage(chatId, `Clique para pagar: ${invoice.pay_url}`);
      
      // Aqui você precisa guardar no banco ou memória o chatId + invoice.id para quando webhook avisar pagamento confirmado, adicionar o usuário
    } catch (error) {
      bot.sendMessage(chatId, 'Erro ao criar invoice. Tente mais tarde.');
      console.error(error);
    }
  }
});

// Aqui você vai implementar o endpoint do webhook para receber notificações do CryptoBot (requer servidor rodando)
const express = require('express');
const app = express();
app.use(express.json());

app.post('/webhook', async (req, res) => {
  const data = req.body;

  // Confirme que é pagamento confirmado (siga docs do CryptoBot)
  if (data.status === 'paid') {
    const chatId = /* recupere o chatId associado a invoice */;

    const canalId = /* canal que o usuário comprou */;

    try {
      // Adiciona o usuário no canal
      await bot.addChatMember(canalId, chatId);
      console.log(`Usuário ${chatId} adicionado no canal ${canalId}`);
    } catch (e) {
      console.error('Erro ao adicionar usuário:', e);
    }
  }
  res.sendStatus(200);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
