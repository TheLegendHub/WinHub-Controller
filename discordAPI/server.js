const express = require('express');
const { Client, GatewayIntentBits } = require('discord.js');
const WebSocket = require('ws');
const cors = require('cors');
const nodemailer = require('nodemailer');
const app = express();
const port = 7000;
// Replace with your email and password (use app password if using Gmail)
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: '',
    pass: '' // Not your main Gmail password
  }
});
app.use(cors());
app.use(express.json());
app.use(express.static('public')); // serve frontend files

// === Discord Bot Setup ===
const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent
  ]
});

// === WebSocket Server Setup ===
const wss = new WebSocket.Server({ noServer: true });
let wsClients = [];

wss.on('connection', (ws) => {
  wsClients.push(ws);
  ws.on('close', () => {
    wsClients = wsClients.filter(client => client !== ws);
  });
});

// === Handle Bot Ready ===
client.once('ready', () => {
  console.log(`Bot is online as ${client.user.tag}`);
});

// === Handle Incoming Discord Messages ===
client.on('messageCreate', (message) => {
  if (!message.author.bot) {
    const reply = `IT Admin: ${message.content}`;

    // Broadcast to all WebSocket clients
    wsClients.forEach(ws => {
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(reply);
      }
    });
  }
});

// === HTTP API Endpoint to Send Message ===
app.post('/send', async (req, res) => {
  const { content } = req.body;
  const channelId = '1333391966070636624'; // Replace with your actual channel ID

  try {
    const channel = await client.channels.fetch(channelId);
    await channel.send(`Computer Lab Teacher:\n${content}`);
    // Send email
    await transporter.sendMail({
      from: 'it3@tapschool.ae',
      to: 'it3@tapschool.ae', // or another recipient
      subject: 'TAPS Computer-Lab Alert',
      text: content
    });
    res.send({ status: 'sent' });
  } catch (err) {
    console.error(err);
    res.status(500).send({ status: 'error', error: err.message });
  }
});

// === Start HTTP Server & Upgrade WebSocket ===
const server = app.listen(port, () => {
  console.log(`HTTP and WebSocket server running on http://localhost:${port}`);
});

server.on('upgrade', (request, socket, head) => {
  wss.handleUpgrade(request, socket, head, (ws) => {
    wss.emit('connection', ws, request);
  });
});

// === Log In to Discord ===
client.login('');
