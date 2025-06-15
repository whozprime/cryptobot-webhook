function adicionarUsuarioAoCanal(userId) {
  const botToken = 8139934655:AAGjqSfquZvWLR1uJGSmrEjejoD5U80aEro

  const inviteLink = https://t.me/+BsbrV8Kd4HJlOWQx

  const mensagem = ✅ Pagamento confirmado!\n\nClique no link abaixo para acessar o canal VIP:\n${inviteLink};

  const payload = {
    chat_id: userId,
    text: mensagem
  };

  const axios = require('axios');

  axios.post(telegramApiUrl, payload)
    .then(response => {
      console.log('Mensagem enviada para o usuário:', response.data);
    })
    .catch(error => {
      console.error('Erro ao enviar mensagem:', error.response ? error.response.data : error);
    });
}
