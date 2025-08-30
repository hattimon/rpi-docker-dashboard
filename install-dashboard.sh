#!/bin/bash
# Instalacja RPi Docker Dashboard

set -e

echo "🚀 Instalacja RPi Docker Dashboard"

# 1️⃣ Aktualizacja systemu
sudo apt update && sudo apt upgrade -y

# 2️⃣ Instalacja potrzebnych pakietów
sudo apt install -y jq wget unzip

# 3️⃣ Utworzenie katalogu panel
mkdir -p ~/panel

# 4️⃣ Pobranie panelu z repo (lub ZIP lokalnie)
if [ ! -f ~/panel/index.html ]; then
    echo "Pobieranie plików panelu..."
    wget -O ~/panel/panel.zip "https://github.com/hattimon/rpi-docker-dashboard/raw/main/panel.zip"
    unzip -o ~/panel/panel.zip -d ~/panel
fi

# 5️⃣ Tworzenie skryptu generującego status
cat <<'EOF' > ~/generate_status.sh
#!/bin/bash
STATUS_FILE="$HOME/panel/status.json"

CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100-$1"%"}')
RAM=$(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100}')
TEMP=$(vcgencmd measure_temp 2>/dev/null | cut -d "=" -f2)
DISK=$(df -h / | tail -1 | awk '{print $5}')
ETH_IP=$(ip addr show eth0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
WIFI_IP=$(ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)
ETH_IP=${ETH_IP:-"brak"}
WIFI_IP=${WIFI_IP:-"brak"}
CONTAINERS=$(docker ps --format '{"name":"{{.Names}}","image":"{{.Image}}","status":"{{.Status}}"}' | jq -s '.')

cat <<JSON > $STATUS_FILE
{
  "system":{"cpu":"$CPU","ram":"$RAM","temp":"$TEMP","disk":"$DISK"},
  "network":{"eth0":"$ETH_IP","wlan0":"$WIFI_IP"},
  "containers": $CONTAINERS
}
JSON
EOF

chmod +x ~/generate_status.sh

# 6️⃣ Dodanie crona do aktualizacji statusu co minutę
(crontab -l 2>/dev/null; echo "* * * * * $HOME/generate_status.sh") | crontab -

# 7️⃣ Pobranie skryptu odinstalowującego dashboard
if [ ! -f ~/uninstall-dashboard.sh ]; then
    wget -O ~/uninstall-dashboard.sh "https://raw.githubusercontent.com/hattimon/rpi-docker-dashboard/main/uninstall-dashboard.sh"
    chmod +x ~/uninstall-dashboard.sh
    echo "✔ Skrypt uninstall-dashboard.sh gotowy do użycia"
fi

# 8️⃣ Tworzenie usługi systemd dla dashboarda
SERVICE_FILE="/etc/systemd/system/rpi-dashboard.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=RPi Docker Dashboard
After=network.target

[Service]
WorkingDirectory=$HOME/panel
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always
User=$USER

[Install]
WantedBy=multi-user.target
EOF

# 9️⃣ Włączenie i start serwisu
sudo systemctl daemon-reload
sudo systemctl enable rpi-dashboard
sudo systemctl restart rpi-dashboard

echo "✅ Instalacja zakończona."
echo "📊 Panel dostępny pod adresem: http://$(hostname -I | awk '{print $1}'):8080/"
echo "🗑️ Jeśli chcesz odinstalować panel, uruchom: ~/uninstall-dashboard.sh"
