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

## Odinstalowanie

Aby całkowicie usunąć RPi Docker Dashboard (bez usuwania Dockera i innych kontenerów), uruchom:

```bash
~/uninstall-dashboard.sh
```
Skrypt:

zatrzymuje i usuwa usługę systemd dla dashboarda,
czyści cron dla generate_status.sh,
usuwa pliki ~/panel/, generate_status.sh oraz install-dashboard.sh.

---

### 🔹 Co zmienia się w repo
```bash
rpi-docker-dashboard/
├─ install-dashboard.sh # zmodyfikowany, dodaje pobranie uninstall-dashboard.sh
├─ generate_status.sh
├─ uninstall-dashboard.sh # nowy plik w repo
├─ panel/
│ └─ index.html
├─ README.md # uzupełniony o sekcję "Odinstalowanie"
└─ .gitignore
```
