#!/bin/bash
cd "$(dirname "$0")"

SERVICE_NAME="clipboard_monitor.service"

if systemctl list-units --all | grep -q "$SERVICE_NAME"; then
    echo "Service $SERVICE_NAME exists. Proceeding with removal."
    sudo systemctl stop "$SERVICE_NAME"
    sudo systemctl disable "$SERVICE_NAME"
    sudo rm "/etc/systemd/system/$SERVICE_NAME"
    sudo systemctl daemon-reload
    echo "Service $SERVICE_NAME has been removed."
else
    echo "Service $SERVICE_NAME does not exist. Nothing to remove."
fi

sudo apt install xclip
sudo apt install -y python3-venv
ENV_DIR="env"

if [ -d "$ENV_DIR" ]; then
    echo "Removing existing virtual environment at $ENV_DIR..."
    rm -rf "$ENV_DIR"
fi
sudo systemctl stop unattended-upgrades
sudo systemctl disable unattended-upgrades
python3 -m venv "$ENV_DIR"
source "$ENV_DIR/bin/activate"
echo "New virtual environment created and activated."
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
