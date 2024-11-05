#!/bin/bash
cd "$(dirname "$0")"

SERVICE_NAME="clipboard_monitor.service"

sudo systemctl stop $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME
sudo rm /etc/systemd/system/$SERVICE_NAME
sudo systemctl daemon-reload

echo "$SERVICE_NAME has been removed and is ready for redeployment."

sudo apt install xclip
sudo apt install -y python3-venv
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
chmod +x "$(pwd)/src/monitor.py"
chmod +x "$(pwd)/src/cl.py"
sudo cp "$(pwd)/src/cl.py" /usr/bin/cl
sudo chmod +x /usr/bin/cl

CURRENT_DIRECTORY=$(pwd)
CURRENT_USER=$(whoami)
SERVICE_FILE="/etc/systemd/system/clipboard_monitor.service"
SCRIPT_PATH="$CURRENT_DIRECTORY/src/monitor.py"
sudo usermod -aG $CURRENT_USER
xhost +SI:localuser:$CURRENT_USER
SERVICE_CONTENT="[Unit]
Description=Clipboard Background Monitoring Service
After=network.target

[Service]
Type=simple
WorkingDirectory=$CURRENT_DIRECTORY 
Environment=VIRTUAL_ENV=$CURRENT_DIRECTORY/env
Environment=PATH=/usr/bin:/usr/local/bin:$CURRENT_DIRECTORY/env/bin:$PATH
Environment="DISPLAY=:1"
Environment="XAUTHORITY=/home/$CURRENT_USER/.Xauthority"
ExecStart=$CURRENT_DIRECTORY/env/bin/python3 $SCRIPT_PATH
Restart=always
User=$CURRENT_USER

[Install]
WantedBy=default.target
"

echo "$SERVICE_CONTENT" | sudo tee $SERVICE_FILE > /dev/null
sudo systemctl daemon-reload
sudo systemctl enable clipboard_monitor.service
sudo systemctl start clipboard_monitor.service
echo "Clipboard monitoring service created and started successfully."
