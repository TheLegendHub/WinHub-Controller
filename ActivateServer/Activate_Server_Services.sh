#!/bin/bash

# Restart Apache2 service
echo "Starting Frontend Services Apache..."
sudo systemctl restart apache2.service || { echo "Failed to restart apache2"; exit 1; }

# Run Python app
echo "Starting Backend Services..."
sudo nohup python /home/it3/Desktop/TAPS/app.py > /home/it3/Desktop/TAPS/logs/flask.log 2>&1 &

# Run Node server
echo "Starting API Backend Handler.."
sudo nohup node /home/it3/Desktop/TAPS/exam-portal/server.js > /home/it3/Desktop/TAPS/logs/exam-portal.log 2>&1 &

# Restart VSFTPD service
echo "Starting FTP Services..."
sudo systemctl restart vsftpd || { echo "Failed to restart vsftpd"; exit 1; }

# Run another Node script
echo "Starting ChatAI-API Server..."
sudo nohup node /home/it3/Desktop/TAPS/AI/node.js > /home/it3/Desktop/TAPS/logs/ai-node.log 2>&1 &

# Run Discord API server script
echo "Starting ChatDiscord-API Server..."
sudo nohup node /home/it3/Desktop/TAPS/discordAPI/server.js > /home/it3/Desktop/TAPS/logs/discord-api.log 2>&1 &

echo "All commands executed."
