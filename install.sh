#!/bin/bash

cd "$(dirname "$0")"

chmod +x ./src/monitor.py
chmod +x ./src/clip.py
sudo cp ./src/clip.py /usr/bin/clip

SERVICE_FILE="/etc/systemd/system/clipboard_monitor.service"
SERVICE_CONTENT="[Unit]
Description=Clipboard Background Monitoring Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /path/to/clipboard_monitor.py  # Adjust the Python path if needed
Restart=always
User=your-username  # Replace 'your-username' with your actual username

[Install]
WantedBy=default.target
"

echo "$SERVICE_CONTENT" | sudo tee $SERVICE_FILE
sudo systemctl daemon-reload
sudo systemctl enable clipboard_monitor.service
sudo systemctl start clipboard_monitor.service
echo "Clipboard monitoring created and started successfully"