# ST-06 — The Last Shell

Vulnerable Linux box for **Ghost Protocol** (Group 06, IE3132): the capstone
challenge, combining service enumeration, credential discovery, and a
sudo/writable-script privilege escalation.

## What's here

| File | Purpose |
|---|---|
| `Dockerfile` | Builds the vulnerable Linux box (Ubuntu 22.04, SSH + an internal HTTP notes service) |
| `entrypoint.sh` | Resets the flag file and the deliberate weak permission on every boot |
| `files/backup.sh` | The "maintenance script" — root-owned, runnable via sudo, left world-writable |
| `files/nexora-ops.sudoers` | Grants `svc_monitor` passwordless sudo on `backup.sh` |
| `files/ops-notes.txt` | Internal handover note leaking `svc_monitor`'s temporary password |
| `reset_st06.sh` | Reference reset script (run the two `docker compose` commands manually from the `ghost-protocol-st03` folder, since that's where `docker-compose.yml` lives) |

## Discovery chain (how a player actually solves this)

1. `nmap -sV` against the host identified in ST-05 shows SSH (22) and an HTTP service (8080).
2. The HTTP service serves `ops-notes.txt` — an internal handover note that leaks
   a temporary account: `svc_monitor` / `MonitorTemp#2026`.
3. Player SSHes in as `svc_monitor`.
4. `sudo -l` shows `svc_monitor` can run `/opt/nexora/scripts/backup.sh` as root, no password.
5. `ls -l` on that script shows it's world-writable (`-rwxrwxrwx`).
6. Player overwrites the script with `/bin/bash -p`, runs it via `sudo`, gets a root shell.
7. `cat /opt/nexora/incident/final_report.txt` for the flag.

## Running it

This service is wired into the shared `docker-compose.yml` in `../ghost-protocol-st03/`
alongside CTFd and ST-03, on the same `ghost_protocol_net` network. From that folder:

```bash
docker compose up -d --build st06-linux
```

- SSH: `localhost:2222` (mapped from the container's port 22, for local testing)
- Ops notes service: `http://localhost:8080/ops-notes.txt`
- For the final isolated deployment, remove the `ports:` mapping on `st06-linux`
  in `docker-compose.yml` so it's reachable only inside `ghost_protocol_net`,
  matching the report's isolation control.

## Testing checklist

- [ ] Functional: `nmap` shows both services; `ops-notes.txt` is readable without auth.
- [ ] Functional: `svc_monitor` can SSH in with the leaked password.
- [ ] Functional: `sudo -l` shows the NOPASSWD rule; `backup.sh` is world-writable.
- [ ] Functional: overwriting `backup.sh` and running it via `sudo` gives a root shell.
- [ ] Functional: `/opt/nexora/incident/final_report.txt` contains the correct flag.
- [ ] Negative: `svc_monitor` cannot read `final_report.txt` directly (root-only, mode 600).
- [ ] Reset: rebuilding the container restores the original `backup.sh` content and permissions.

## Notes

- Flag: `NEXORA{sh3ll_fr0m_4_wr1t4bl3_scr1pt}` (overridable via the `ST06_FLAG`
  environment variable in `docker-compose.yml`, keep them in sync).
- `svc_monitor`'s password and the sudoers rule are placeholder dev values —
  this is a deliberately vulnerable box, never expose it outside the isolated
  CTF network.
