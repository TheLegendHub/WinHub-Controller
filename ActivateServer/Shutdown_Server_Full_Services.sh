#!/bin/bash

echo "Stopping Backend Services..."
sudo pkill -f '/home/it3/Desktop/TAPS/app.py'

echo "Stopping API Backend Handler..."
sudo pkill -f '/home/it3/Desktop/TAPS/exam-portal/server.js'

echo "Stopping ChatAI-API Server..."
sudo pkill -f '/home/it3/Desktop/TAPS/AI/node.js'

echo "Stopping ChatDiscord-API Server..."
sudo pkill -f '/home/it3/Desktop/TAPS/discordAPI/server.js'

echo "Stopping Frontend Apache Server..."
sudo systemctl stop apache2.service

echo "Stopping FTP Services..."
sudo systemctl stop vsftpd

echo "All services stopped."
