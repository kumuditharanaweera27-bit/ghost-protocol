#!/bin/bash
set -e

# (Re)create the flag file fresh on every boot - mirrors ST-03's reset pattern
FLAG_DEFAULT='NEXORA{sh3ll_fr0m_4_wr1t4bl3_scr1pt}'
FLAG_VALUE="${ST06_FLAG:-$FLAG_DEFAULT}"

mkdir -p /opt/nexora/incident
echo "$FLAG_VALUE" > /opt/nexora/incident/final_report.txt
chmod 600 /opt/nexora/incident/final_report.txt
chown root:root /opt/nexora/incident/final_report.txt

# Make sure the deliberate weakness is in place even after a restart
chmod 777 /opt/nexora/scripts/backup.sh

# Start the internal ops-notes HTTP service (the "one additional vulnerable service")
python3 -m http.server 8080 --directory /srv/ops-portal &

# Start SSH in the foreground so the container stays alive
/usr/sbin/sshd -D
