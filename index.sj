index.sj- Bot Telegram integrado com CryptoBot e canal VIP

const express = require('express');
const axios = require('axios');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

// Configurações
const TELEGRAM_BOT_TOKEN = '8050991119:AAF2bGZt0cUsr6IXEq-sOsAxFaNA7ApD6f0';
const CRYPTOBOT_TOKEN = '416539:AAoXpsgTmKb1zgW8irAQb2pjW0JrZx8FXuP';
const TELEGRAM_API = `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}`;
const CANAL_VIP = '@Vip_conteudos_fullVIPContent'; // Ajustado para formato @Canal (não use espaço ou caracteres especiais no username oficial do canal)

// Função para enviar mensagem no Telegram
async function sendMessage(chat_id, text) {
  try {
    await axios.post(`${TELEGRAM_API}/sendMessage`, {
      chat_id,
      text,
      parse_mode: 'Markdown',
    });
  } catch (error) {
    console.error('Erro ao enviar mensagem:', error.response?.data || error.message);
  }
}

// Função para adicionar membro ao canal VIP via convite (via bot só consegue mandar convite, para adicionar direto precisa admin e bot admin)
async function addUserToVipChannel(userId) {
  try {
    // Aqui não tem API oficial do Telegram para adicionar membro direto em canal,
    // normalmente usa-se link de convite ou bot admin adiciona membro via chat invite link.
    // Então a estratégia prática é enviar o link do canal VIP para o usuário.
    const inviteLink = 'https://t.me/+SeuLinkDeConviteAqui'; // Substitua pelo link real do seu canal VIP
    await sendMessage(userId, `Parabéns pela compra! Você já pode entrar no canal VIP: ${inviteLink}`);
  } catch (error) {
    console.error('Erro ao tentar adicionar usuário ao canal VIP:', error.message);
  }
}

// Roteamento webhook para receber updates Telegram e notificações CryptoBot
app.post('/webhook', async (req, res) => {
  const update = req.body;

  // Caso seja update Telegram (mensagem do usuário)
  if (update.message) {
    const chatId = update.message.chat.id;
    const text = update.message.text;

    if (!text) return res.sendStatus(200);

    if (text === '/start') {
      await sendMessage(chatId, 'Bem-vindo! Use /comprar para gerar seu link de pagamento e /status para ver seus pagamentos.');
    } else if (text === '/comprar') {
      // Criar invoice no CryptoBot para o usuário
      try {
        const invoice = await axios.post(`https://api.crypt.bot/v1/invoice/create`, {
          token: CRYPTOBOT_TOKEN,
          amount: 10, // valor fixo para exemplo, ajuste o valor que quiser cobrar
          coin: 'BRL',
          payload: `user${chatId}`,
          allow_comments: false,
          allow_anonymous: false,
          // descrição curta do produto
          title: 'Acesso VIP - Conteúdo Full',
        });
        const payUrl = invoice.data.result.pay_url;
        await sendMessage(chatId, `Para completar sua compra, acesse o link abaixo:\n${payUrl}`);
      } catch (error) {
        console.error('Erro ao criar invoice:', error.response?.data || error.message);
        await sendMessage(chatId, 'Desculpe, ocorreu um erro ao gerar o link de pagamento. Tente novamente mais tarde.');
      }
    } else if (text === '/status') {
      // Aqui poderia implementar uma consulta simples ao status do pagamento do usuário (ex: pelo payload)
      await sendMessage(chatId, 'Funcionalidade de status ainda não implementada.');
    } else {
      await sendMessage(chatId, 'Comando não reconhecido. Use /start, /comprar ou /status.');
    }

    return res.sendStatus(200);
  }

  // Caso seja notificação do CryptoBot (webhook de pagamento)
  if (update.data && update.data.type === 'invoice.paid') {
    const payload = update.data.payload; // ex: user123456789
    const userIdStr = payload?.match(/user(\d+)/);
    if (userIdStr && userIdStr[1]) {
      const userId = parseInt(userIdStr[1]);
      await sendMessage(userId, 'Pagamento confirmado! Você agora tem acesso VIP.');
      await addUserToVipChannel(userId);
    }
    return res.sendStatus(200);
  }

  // Ignorar outros updates
  res.sendStatus(200);
});

// Iniciar servidor
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Bot rodando na porta ${PORT}`);
});
