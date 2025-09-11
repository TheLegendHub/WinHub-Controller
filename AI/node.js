const express = require('express');
const axios = require('axios');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const nodemailer = require('nodemailer');
const schedule = require('node-schedule');
const chrono = require('chrono-node');

const app = express();
app.use(express.json());
app.use(cors());

// CONFIGURATION
const GROQ_API_KEY = ''; // Replace with your real key
const EMAIL_SENDER = ';
const EMAIL_PASSWORD = 'p'; // App password
const DEFAULT_EMAIL_RECIPIENT = '';

// Email transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: EMAIL_SENDER,
    pass: EMAIL_PASSWORD
  }
});

function sendEmail(to, subject, text) {
  const mailOptions = {
    from: EMAIL_SENDER,
    to,
    subject,
    text
  };
  return transporter.sendMail(mailOptions);
}

function scheduleReminder(email, subject, message, date) {
  schedule.scheduleJob(date, () => {
    sendEmail(email, subject, message)
      .then(() => console.log(`✅ Reminder email sent to ${email} at ${new Date()}`))
      .catch(err => console.error('❌ Failed to send reminder:', err));
  });
}

// Load info.txt
const infoFiles = ['info.txt'];
const infoMessages = [];

infoFiles.forEach((filename) => {
  const filePath = path.join(__dirname, filename);
  try {
    const content = fs.readFileSync(filePath, 'utf-8');
    infoMessages.push({
      role: 'system',
      content: `Background info from ${filename}:\n${content}`
    });
    console.log(`${filename} loaded successfully.`);
  } catch (err) {
    console.error(`Failed to read ${filename}:`, err.message);
  }
});

// In-memory chat + email store
let conversationHistory = [
  { role: 'system', content: 'You are a helpful assistant.' },
  ...infoMessages
];

let currentUserEmail = null;

// Chat endpoint
app.post('/chat', async (req, res) => {
  const userMessage = req.body.message;
  conversationHistory.push({ role: 'user', content: userMessage });

  // Try to extract email from message
  const emailMatch = userMessage.match(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z]{2,}\b/i);
  if (emailMatch) {
    currentUserEmail = emailMatch[0];
    console.log(`📧 Captured email: ${currentUserEmail}`);
  }

  // Try to detect reminder request
  const remindMatch = userMessage.match(/remind me to (.+) at (.+)/i);
  if (remindMatch) {
    const task = remindMatch[1];
    const timeStr = remindMatch[2];

    const date = chrono.parseDate(timeStr);
    if (date) {
      const targetEmail = currentUserEmail || DEFAULT_EMAIL_RECIPIENT;
      scheduleReminder(targetEmail, 'Reminder from your TAPS AI Assistant Agent', task, date);
      console.log(`⏰ Scheduled reminder: "${task}" to ${targetEmail} at ${date}`);
    } else {
      console.warn('⚠️ Invalid time:', timeStr);
    }
  }

  // Call Groq AI
  try {
    const response = await axios.post(
      'https://api.groq.com/openai/v1/chat/completions',
      {
        model: 'llama-3.1-8b-instant',
        messages: conversationHistory,
        temperature: 0.7
      },
      {
        headers: {
          Authorization: `Bearer ${GROQ_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    const reply = response.data.choices[0].message.content;
    conversationHistory.push({ role: 'assistant', content: reply });

    res.json({ reply });
  } catch (err) {
    console.error('❌ Error from Groq:', err.response?.data || err.message);
    res.status(500).json({ error: 'Failed to get response from Groq' });
  }
});

// Reset endpoint
app.post('/reset', (req, res) => {
  conversationHistory = [
    { role: 'system', content: 'You are a helpful assistant.' },
    ...infoMessages
  ];
  currentUserEmail = null;
  res.json({ message: 'Conversation history and email reset.' });
});

// Start server
const PORT = process.env.PORT || 9000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running at http://0.0.0.0:${PORT}/chat`);
});

