#!/bin/bash
# Instalacja RPi Docker Dashboard w katalogu /root/panel

set -e

echo "🚀 Instalacja RPi Docker Dashboard w /root/panel"

# 1️⃣ Aktualizacja systemu
sudo apt update && sudo apt upgrade -y

# 2️⃣ Instalacja potrzebnych pakietów, w tym cron, libraspberrypi-bin i docker jeśli brak
sudo apt install -y jq wget unzip python3 cron libraspberrypi-bin docker.io

# Upewnij się, że cron jest włączony i działa
sudo systemctl enable cron
sudo systemctl start cron

# Dodaj użytkownika root do grupy docker, jeśli nie jest
sudo usermod -aG docker root

# 3️⃣ Utworzenie katalogu panel w /root
INSTALL_DIR="/root/panel"
mkdir -p "$INSTALL_DIR"

# 4️⃣ Pobranie panelu z repo (lub ZIP lokalnie)
if [ ! -f "$INSTALL_DIR/index.html" ]; then
    echo "Pobieranie plików panelu..."
    wget -O "$INSTALL_DIR/panel.zip" "https://github.com/hattimon/rpi-docker-dashboard/raw/main/panel.zip"
    unzip -o "$INSTALL_DIR/panel.zip" -d "$INSTALL_DIR"
fi

# 5️⃣ Tworzenie skryptu generującego status (z dostosowaniem TEMP dla Ubuntu)
cat <<'EOF' > /root/generate_status.sh
#!/bin/bash
STATUS_FILE="/root/panel/status.json"

CPU=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100-$1"%"}')
RAM=$(free | grep Mem | awk '{printf "%.1f%%", $3/$2 * 100}')
TEMP=$(vcgencmd measure_temp 2>/dev/null | cut -d "=" -f2 || cat /sys/class/thermal/thermal_zone0/temp | awk '{print $1/1000 "°C"}')
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

chmod +x /root/generate_status.sh

# 6️⃣ Dodanie crona do aktualizacji statusu co minutę (sprawdź, czy wpis już istnieje, aby uniknąć duplikatów)
CRON_JOB="* * * * * /root/generate_status.sh"
if ! crontab -l | grep -q "/root/generate_status.sh"; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "✔ Dodano zadanie cron: $CRON_JOB"
else
    echo "✔ Zadanie cron już istnieje."
fi

# Uruchom skrypt generujący status natychmiast po instalacji
/root/generate_status.sh

# 7️⃣ Pobranie skryptu odinstalowującego dashboard
if [ ! -f /root/uninstall-dashboard.sh ]; then
    wget -O /root/uninstall-dashboard.sh "https://raw.githubusercontent.com/hattimon/rpi-docker-dashboard/main/uninstall-dashboard.sh"
    chmod +x /root/uninstall-dashboard.sh
    echo "✔ Skrypt uninstall-dashboard.sh gotowy do użycia"
fi

# 8️⃣ Tworzenie usługi systemd dla dashboarda
SERVICE_FILE="/etc/systemd/system/rpi-dashboard.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=RPi Docker Dashboard
After=network.target

[Service]
WorkingDirectory=/root/panel
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# 9️⃣ Włączenie i start serwisu
sudo systemctl daemon-reload
sudo systemctl enable rpi-dashboard
sudo systemctl restart rpi-dashboard

echo "✅ Instalacja zakończona."
echo "📊 Panel dostępny pod adresem: http://$(hostname -I | awk '{print $1}'):8080/"
echo "🗑️ Jeśli chcesz odinstalować panel, uruchom: /root/uninstall-dashboard.sh"
