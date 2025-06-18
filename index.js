const express = require('express');
const axios = require('axios');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

// Configs
const TELEGRAM_BOT_TOKEN = '8050991119:AAF2bGZt0cUsr6IXEq-sOsAxFaNA7ApD6f0';
const CRYPTOBOT_TOKEN = '416539:AAoXpsgTmKb1zgW8irAQb2pjW0JrZx8FXuP';
const TELEGRAM_API = `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}`;
const CANAL_VIP = 'https://t.me/+SeuLinkDeConviteAqui'; // <- Troque pelo link real do canal

// Enviar mensagem simples
async function sendMessage(chat_id, text) {
  try {
    await axios.post(`${TELEGRAM_API}/sendMessage`, {
      chat_id,
      text,
      parse_mode: 'Markdown',
    });
  } catch (error) {
    console.error('Erro ao enviar mensagem:', error.message);
  }
}

// Menu interativo com botões
async function sendMenu(chat_id) {
  try {
    await axios.post(`${TELEGRAM_API}/sendMessage`, {
      chat_id,
      text: 'O que você deseja fazer? 👇',
      reply_markup: {
        inline_keyboard: [
          [{ text: '💳 Comprar Acesso VIP', callback_data: 'comprar' }],
          [{ text: '📦 Ver Status do Pagamento', callback_data: 'status' }],
          [{ text: '❓ Ajuda', callback_data: 'ajuda' }]
        ]
      }
    });
  } catch (error) {
    console.error('Erro ao mostrar menu:', error.message);
  }
}

// Envia link de convite para canal VIP
async function enviarConviteVIP(userId) {
  await sendMessage(userId, `✅ Pagamento confirmado! Bem-vindo ao canal VIP:\n${CANAL_VIP}`);
}

// Webhook
app.post('/webhook', async (req, res) => {
  const update = req.body;

  // Mensagem normal
  if (update.message) {
    const chatId = update.message.chat.id;
    const text = update.message.text;

    if (text === '/start') {
      await sendMessage(chatId, `Olá! Eu sou o bot de acesso VIP.\n\nClique abaixo para navegar 👇`);
      await sendMenu(chatId);
    }

    if (text === '/comprar') {
      await gerarInvoice(chatId);
    }

    if (text === '/ajuda') {
      await sendMessage(chatId, `Use /comprar para adquirir o acesso VIP.\nApós o pagamento, você receberá o link do canal automaticamente.`);
    }

    if (text === '/status') {
      await sendMessage(chatId, `Esta função será implementada em breve. Fique ligado!`);
    }

    return res.sendStatus(200);
  }

  // Clique nos botões do menu
  if (update.callback_query) {
    const chatId = update.callback_query.from.id;
    const data = update.callback_query.data;

    if (data === 'comprar') {
      await gerarInvoice(chatId);
    }

    if (data === 'ajuda') {
      await sendMessage(chatId, `Use o botão "Comprar Acesso VIP" para gerar seu link de pagamento via CryptoBot.\nDepois, você receberá o link do canal automaticamente!`);
    }

    if (data === 'status') {
      await sendMessage(chatId, `Status de pagamento ainda não implementado, mas será em breve!`);
    }

    return res.sendStatus(200);
  }

  // Webhook do CryptoBot - pagamento confirmado
  if (update.data && update.data.type === 'invoice.paid') {
    const payload = update.data.payload;
    const userIdStr = payload?.match(/user(\d+)/);
    if (userIdStr && userIdStr[1]) {
      const userId = parseInt(userIdStr[1]);
      await enviarConviteVIP(userId);
    }

    return res.sendStatus(200);
  }

  res.sendStatus(200);
});

// Função para gerar invoice
async function gerarInvoice(chatId) {
  try {
    const invoice = await axios.post('https://api.crypt.bot/v1/invoice/create', {
      token: CRYPTOBOT_TOKEN,
      amount: 10,
      coin: 'BRL',
      payload: `user${chatId}`,
      allow_comments: false,
      allow_anonymous: false,
      title: 'Acesso VIP - Conteúdo Full'
    });

    const payUrl = invoice.data.result.pay_url;
    await sendMessage(chatId, `Clique no link abaixo para fazer o pagamento:\n\n${payUrl}`);
  } catch (error) {
    console.error('Erro ao criar invoice:', error.message);
    await sendMessage(chatId, 'Erro ao gerar link de pagamento. Tente novamente mais tarde.');
  }
}

// Subir servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Bot rodando na porta ${PORT}`);
});
