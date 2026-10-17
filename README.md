# Homelab-Projekt

Ein selbst aufgebautes Homelab zum praktischen Üben von Systemadministration und Netzwerktechnik.

## Überblick

Das Projekt begann als vollständig virtualisiertes Lab mit **VirtualBox** und wird aktuell um physische Hardware (ein Raspberry Pi 3) erweitert, um virtuelle und reale Infrastruktur zu kombinieren.

## Teil 1: Virtuelles Lab (VirtualBox)

**Stack:**
- Ubuntu Server 26.04 LTS (VM)
- SSH
- Apache2
- Samba

**Was umgesetzt wurde:**
- Kompletter Neuaufbau des Homelabs auf VirtualBox
- Konfiguration von SSH, Apache2 und Samba auf Ubuntu Server
- Überprüfung der Samba-Dateifreigabe durch Übertragung einer Datei von einem Windows-Host auf die Ubuntu-Server-VM, bestätigt mit `ls -l`

**Gelöste Probleme:**
- **Captive Portal blockierte Netzwerkzugriff:** ein öffentliches WLAN blockierte den Netzwerkverkehr der VM über ein Captive Portal; gelöst durch Wechsel von VM/Host auf ein Heimnetzwerk ohne Captive Portal
- **Samba-Schreibrechte:** Schreibzugriffe schlugen fehl, da der freigegebene Ordner `nobody:nogroup` gehörte; behoben mit `chmod -R 0777` auf dem freigegebenen Verzeichnis
- **Windows-Gastzugriff blockiert:** Windows blockierte standardmäßig den Gastzugriff auf die Samba-Freigabe; die Einstellungen mussten angepasst werden, um die Verbindung zuzulassen
- Zusätzlich trat während des Neuaufbaus eine Warnung zu einem fehlerhaften Grafiktreiber auf, die ebenfalls behoben wurde

**Monitoring-Skript — `lab_healthcheck.sh`:**
Ein Bash-Skript, das den Zustand der zentralen Lab-Dienste prüft. Es:
- prüft die Erreichbarkeit des Standard-Gateways
- verifiziert über `systemctl is-active`, ob `ssh`, `apache2` und `smbd` aktiv sind
- prüft, ob die Ports 22, 80 und 445 lokale Verbindungen annehmen
- gibt farbige `[OK]`/`[FAIL]`-Statuszeilen aus
- protokolliert zeitgestempelte Ergebnisse in `lab_healthcheck.log`
- beendet sich mit Statuscode 0 oder 1, sodass es später in `cron` oder ein anderes Monitoring eingebunden werden kann

Wird direkt auf der Ubuntu-Server-VM ausgeführt.

## Teil 2: Physische Hardware

Erweiterung des Labs um einen **Raspberry Pi 3 Model B** als physischen Server neben den virtuellen Maschinen.

**Warum:** Das virtuelle Lab deckt die Software-Ebene ab, aber ein echtes Gerät bringt zusätzliche praktische Erfahrung mit physischer Hardware und Netzwerktechnik.

**Netzwerkaufbau:**
Da kein klassischer Heimrouter vorhanden ist, läuft die Internetverbindung über den mobilen Hotspot eines Smartphones:

```text
Smartphone-Hotspot ──(WLAN)──> GL.iNet-Router (OpenWrt, Repeater-Modus) ──(Ethernet)──> Raspberry Pi
Laptop ──(WLAN)──> GL.iNet-Router
```

**Umgesetzt:**
- Raspberry Pi OS Lite (32-Bit) mit dem Raspberry Pi Imager geflasht (headless: Hostname, Lokalisierung, Benutzerkonto, SSH)
- GL.iNet GL-AR300M16-Ext als Router eingerichtet und im Repeater-Modus mit dem Hotspot verbunden
- Pi per Ethernet angebunden; SSH-Zugriff und Internetverbindung (Ping) bestätigt
- Samba-Dateiserver auf dem Pi installiert und eine Freigabe eingerichtet
- Berechtigungen diesmal gruppenbasiert gelöst (Gruppe `sambashare`, setgid-Verzeichnis, `valid users = @sambashare`) statt mit `chmod -R 0777` wie im virtuellen Lab
- Schreibzugriff von Windows aus getestet: Die Datei erscheint auf dem Pi mit korrektem Besitzer und korrekter Gruppe

**Hinweis zum Datenvolumen:** Da die Verbindung über einen mobilen Hotspot mit begrenztem Datenvolumen läuft, werden größere System-Updates (`apt upgrade`) bewusst aufgeschoben.

**Geplante nächste Schritte:**
- `lab_healthcheck.sh` erweitern, sodass auch der Pi und seine Dienste überwacht werden
- Langfristig: Praxis mit einem Managed Switch und VLANs zur Netzwerksegmentierung





---

*Dieses Projekt wird fortlaufend weiterentwickelt und aktualisiert.*

