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

## Teil 2: Physische Hardware (in Arbeit)

Erweiterung des Labs um einen **Raspberry Pi 3** als physischen Server neben den virtuellen Maschinen.

**Warum:** Das virtuelle Lab deckt die Software-Ebene ab, aber ein echtes Gerät bringt zusätzliche praktische Erfahrung mit physischer Hardware und Netzwerktechnik.

**Aktueller Stand:**
- Raspberry Pi OS Lite (32-Bit) mit dem Raspberry Pi Imager auf den Pi geflasht
- Hostname, Lokalisierung, Benutzerkonto und SSH-Zugriff (Passwort-Authentifizierung) konfiguriert

**Geplante nächste Schritte:**
- Pi per Ethernet mit dem Netzwerk verbinden und SSH-Zugriff bestätigen
- Samba-Dateiserver auf dem Pi einrichten, als Erweiterung des virtuellen Labs
- `lab_healthcheck.sh` (oder ein ähnliches Skript) erweitern, um auch die Dienste des Pi zu überwachen
- Langfristig: Praxis mit einem Managed Switch und VLANs zur Netzwerksegmentierung

## Roadmap

Weitere geplante Erweiterungen des Labs:
- Eine Datenbank-Komponente
- Zusätzliche Sicherheitsmaßnahmen
- Mehrere VMs, verbunden über eine Firewall
- Ein einfaches Ticketsystem

---

*Dieses Projekt wird fortlaufend weiterentwickelt und aktualisiert.*

