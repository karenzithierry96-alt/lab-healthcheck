# Lab Health Check

A small Bash script that checks whether the core services in my
VirtualBox home lab (SSH, Apache2, Samba) are running and reachable,
and confirms the VM can reach its gateway.

## Why I built it

I set up SSH, Apache2, and Samba manually while building the lab. After
restarting the VM a few times during networking troubleshooting, I got
tired of checking each service by hand — so I automated the check.
It's a small step from "I can configure services" to "I can also
automate and monitor them," which is closer to real systems
integration work.

## What it checks

1. Default gateway reachability (basic network sanity check)
2. Whether `ssh`, `apache2`, and `smbd` services are active
   (`systemctl is-active`)
3. Whether ports 22 (SSH), 80 (Apache2), and 445 (Samba) actually
   accept connections locally

## How it works

- Each check prints a colored `[OK]` / `[FAIL]` line to the terminal
- Every result is also written to `lab_healthcheck.log` with a
  timestamp, so I can show a history of runs, not just one snapshot
- Script exits with code `0` if everything passed, `1` if something
  failed — so it could later be hooked into `cron` or a monitoring
  setup

## Usage

```bash
chmod +x lab_healthcheck.sh
./lab_healthcheck.sh
```

Run it directly on the Ubuntu Server VM (not the host), since it
checks local service status.

## Possible next steps

- Run it automatically via `cron` every 5 minutes
- Send an alert (e.g. email or a simple webhook) on `FAIL`
- Extend it to check disk space and open SSH login attempts
