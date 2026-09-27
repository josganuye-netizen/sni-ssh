FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    stunnel4 \
    openssl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd /var/run/stunnel

# Membuat satu sertifikat .pem gabungan yang valid untuk Stunnel
RUN openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
    -subj "/C=ID/ST=Jakarta/L=Jakarta/O=RailwaySSH/CN=localhost" \
    -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem

COPY entrypoint.sh /entrypoint.sh
COPY addssh /usr/local/bin/addssh
COPY delssh /usr/local/bin/delssh
COPY listssh /usr/local/bin/listssh
RUN chmod +x /entrypoint.sh /usr/local/bin/addssh /usr/local/bin/delssh /usr/local/bin/listssh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
