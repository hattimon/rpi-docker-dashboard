# RPi Docker Dashboard

Prosty panel monitorujący Raspberry Pi i kontenery Docker.  
Pokazuje status systemu, aktywne kontenery oraz połączenia sieciowe w trybie ciemnym. Automatyczna aktualizacja co kilka sekund.

## Instalacja

```bash
wget -O install-dashboard.sh https://raw.githubusercontent.com/hattimon/rpi-docker-dashboard/main/install-dashboard.sh
chmod +x install-dashboard.sh
sudo ./install-dashboard.sh
```

## Dostęp

Po instalacji panel jest dostępny w katalogu `~/panel/index.html`.  
Odświeżany co 5 sekund automatycznie, pokazuje CPU, RAM, temperaturę, użycie dysku, IP sieci oraz status wszystkich kontenerów Docker.
