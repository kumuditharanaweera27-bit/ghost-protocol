# ST-03 — The Open Door (+ CTFd platform setup)

Implementation for Kumuditha's part of **Ghost Protocol** (Group 06, IE3132):
the vulnerable Flask/SQLite employee portal, and the CTFd platform it plugs into.

## What's here

| File | Purpose |
|---|---|
| `app.py` | The vulnerable Flask app (SQL injection login bypass → restricted area → flag + archive) |
| `templates/`, `static/` | Portal pages: landing, login, dashboard, restricted, denied, directory, announcements |
| `artifacts/` | Drop the real `incident_archive.enc` here (from Fernando's ST-04 work) |
| `Dockerfile` | Builds the disposable ST-03 web box, runs as non-root |
| `docker-compose.yml` | Brings up CTFd + its MariaDB/Redis + ST-03, all on the `10.10.20.0/24` isolated network |
| `reset_st03.sh` | One-command reset: rebuild + recreate the container with a fresh DB |

## Discovery chain (how a player actually solves this)

1. Landing page → public **Staff Directory** and **Announcements** links (no login needed)
2. Directory lists `admin` as a real username; Announcements hints the login system is "overdue for a rebuild"
3. Player checks the login page's source and finds a comment about a "legacy auth module... flagged in last security review"
4. Player tries `admin' --` as the username (any password) → SQL comment strips the password check → logged in as admin
5. Dashboard shows a link to the Restricted Area → flag + `incident_archive.enc` download

## 1. Run it locally first (sanity check before wiring into CTFd)

```bash
cd ghost-protocol-st03
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python app.py
# visit http://localhost:5000
```

## 2. Bring up the full stack (CTFd + ST-03) with Docker

```bash
docker compose up -d --build
```

- CTFd: `http://localhost:8000` (initial setup wizard runs on first visit —
  create the admin account, set the CTF name "Ghost Protocol", and event info).
- `nexora-portal` is **not** published to the host by default — it's reachable
  only inside `ghost_protocol_net`, matching the report's isolation control.
  For local testing, uncomment the `ports: ["5000:5000"]` line under
  `st03-web` in `docker-compose.yml`.

## 3. Configure the ST-03 challenge in CTFd

1. Log into CTFd admin → **Challenges → Create Challenge**.
2. Name: `ST-03 — The Open Door`. Category: `Web Security`.
3. Description — paste the scenario text from the report (portal address,
   "find the restricted area", no further technical hints in the description itself).
4. Flag: **Static**, exact match, value = `NEXORA{sql1_th3_0p3n_d00r}`
   (or whatever `ST03_FLAG` is set to in `docker-compose.yml` — keep them in sync).
5. Hints (3-hint, escalating-penalty model from the report):
   - Hint 1 (−10%): "Don't assume all input is handled safely."
   - Hint 2 (−10%): "Compare behaviour across different input values."
   - Hint 3 (−15%): "Consider whether input reaches a database query."
6. Attach no downloadable file to the challenge itself — the archive is earned
   in-app via the restricted-area download, proving exploitation rather than
   just reading the file off CTFd directly.

## 4. Testing checklist (maps to Section 10 of the report)

- [ ] Functional: normal login works for `jmorales`/`autumn2025`, dashboard renders.
- [ ] Functional: SQLi bypass (`admin' --`) logs in as admin, reaches `/restricted`, flag + archive download work.
- [ ] Negative: non-admin accounts cannot reach `/restricted` directly by URL (expect 403).
- [ ] Isolation: `nexora-portal` cannot reach the Internet or the CTFd admin network.
- [ ] Reset: `./reset_st03.sh` reseeds the DB and clears session state.
- [ ] CTFd: correct flag accepted once, wrong flag rejected, hints deduct points as configured.

## Notes

- `app.secret_key` and the MariaDB/CTFd passwords in `docker-compose.yml` are
  placeholder dev values — rotate them before anyone outside your group runs this.
- Swap in the real `incident_archive.enc` from Fernando before the pilot test,
  or the download link will serve the placeholder content instead.
