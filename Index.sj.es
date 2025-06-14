const message = req.body.message;

if (message?.text === '/start') {
  await axios.post(`https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage`, {
    chat_id: message.chat.id,
    text: "👋 Welcome! Use /vip to get access to the exclusive channel."
  });
}