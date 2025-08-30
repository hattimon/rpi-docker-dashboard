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

Po instalacji panel jest dostępny w katalogu `/root/panel/index.html`.  
Odświeżany co 5 sekund automatycznie, pokazuje CPU, RAM, temperaturę, użycie dysku, IP sieci oraz status wszystkich kontenerów Docker.  

✅ Panel będzie dostępny pod adresem:  
```
http://<IP_RaspberryPi>:8080/
```
Gdzie `<IP_RaspberryPi>` możesz sprawdzić poleceniem:
```bash
hostname -I | awk '{print $1}'
```

## Odinstalowanie

Aby całkowicie usunąć RPi Docker Dashboard (bez usuwania Dockera i innych kontenerów), uruchom:

```bash
/root/uninstall-dashboard.sh
```

Skrypt:
- zatrzymuje i usuwa usługę systemd dla dashboarda,  
- czyści cron dla `/root/generate_status.sh`,  
- usuwa pliki `/root/panel/`, `generate_status.sh` oraz `install-dashboard.sh`.

---

### 🔹 Co zmienia się w repo
```bash
rpi-docker-dashboard/
├─ install-dashboard.sh # zmodyfikowany, instaluje w /root i dodaje pobranie uninstall-dashboard.sh
├─ generate_status.sh
├─ uninstall-dashboard.sh # nowy plik w repo
├─ panel/
│ └─ index.html
├─ README.md # uzupełniony o sekcję "Odinstalowanie"
└─ .gitignore
```

