FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
        openssh-server \
        python3 \
        sudo \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Low-privilege service account used for automated health checks
RUN useradd -m -s /bin/bash svc_monitor && \
    echo "svc_monitor:MonitorTemp#2026" | chpasswd

# Maintenance script, intended to run as root via sudo - left world-writable (the deliberate weakness)
COPY files/backup.sh /opt/nexora/scripts/backup.sh
RUN chown root:root /opt/nexora/scripts/backup.sh && \
    chmod 777 /opt/nexora/scripts/backup.sh

# svc_monitor may run the backup script as root, no password required
COPY files/nexora-ops.sudoers /etc/sudoers.d/nexora-ops
RUN chmod 440 /etc/sudoers.d/nexora-ops && \
    chown root:root /etc/sudoers.d/nexora-ops

# Internal ops notes portal - the "one additional vulnerable service"
RUN mkdir -p /srv/ops-portal
COPY files/ops-notes.txt /srv/ops-portal/ops-notes.txt

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 8080

CMD ["/entrypoint.sh"]
