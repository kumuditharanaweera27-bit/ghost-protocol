FROM ubuntu:22.04

# Ghost Protocol — ST-06 "The Last Shell"
# Deliberately vulnerable Linux target. ISOLATED CTF NETWORK ONLY.

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server sudo vim less nano \
        iproute2 iputils-ping net-tools ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd && ssh-keygen -A

# Foothold account: amorgan. MUST match the password leaked in ST-05 PCAP.
ARG AMORGAN_PASSWORD=Sunset2026!

RUN useradd -m -s /bin/bash amorgan && \
    echo "amorgan:${AMORGAN_PASSWORD}" | chpasswd && \
    useradd -m -s /bin/bash jlee && \
    echo "jlee:$(head -c16 /dev/urandom | base64)" | chpasswd && \
    useradd -r -s /usr/sbin/nologin svc-backup && \
    echo "root:$(head -c16 /dev/urandom | base64)" | chpasswd

# THE ONE INTENDED MISCONFIGURATION (GTFOBins privesc)
RUN echo "amorgan ALL=(root) NOPASSWD: /usr/bin/find" > /etc/sudoers.d/90-nexora && \
    chmod 440 /etc/sudoers.d/90-nexora

RUN mkdir -p /opt/nexora/incident
COPY final_report.txt /opt/nexora/incident/final_report.txt
RUN chown root:root /opt/nexora/incident/final_report.txt && \
    chmod 600 /opt/nexora/incident/final_report.txt

RUN mkdir -p /opt/nexora/scripts && \
    printf '#!/bin/bash\n# nightly backup (currently disabled)\n' > /opt/nexora/scripts/backup.sh && \
    chown root:root /opt/nexora/scripts/backup.sh && chmod 744 /opt/nexora/scripts/backup.sh && \
    printf 'Welcome to NEXORA-INT-01\nAuthorized personnel only.\n' > /etc/motd && \
    printf 'db_host=127.0.0.1\ndb_user=reporting\n# TODO: rotate creds (ticket NEX-1182)\n' > /home/amorgan/notes.txt && \
    chown amorgan:amorgan /home/amorgan/notes.txt && chmod 644 /home/amorgan/notes.txt

RUN sed -i 's/#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
