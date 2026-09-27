#!/bin/bash

USER_NAME="${SSH_USER:-kopi}"
USER_PASS="${SSH_PASSWORD:-kopi}"
MAIN_PORT="${PORT:-8080}"

echo "[*] Mengonfigurasi User SSH..."
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USER_NAME"
    usermod -aG sudo "$USER_NAME"
fi
echo "$USER_NAME:$USER_PASS" | chpasswd

echo "[*] Mengonfigurasi SSH Banner..."
cat << 'BANNER_HTML' > /etc/ssh/banner
<p style="text-align:center">
<font color="blue"><b>क═══════क⊹⊱✫⊰⊹क═══════क</b></font><br>
<font color="red"><b>  LAYANAN CF VPN KUNCUNG </b></font><br>
<font color="blue"><b>क═══════क⊹⊱✫⊰⊹क═══════क</b></font><br>
<font color="purple"><b>BACA PERATURAN DI BAWAH INI : </b></font><br>
<br>
<font color="green"><b>- DILARANG DDOS</b></font><br>
<font color="red"><b>- DILARANG MULTI LOGIN</b></font><br>
<font color="green"><b>- DILARANG UNTUK HAL KRIMINAL</b></font><br>
<font color="red"><b>- DILARANG BERMAIN GAME PLAYSTATION</b></font><br>
<font color="green"><b>- DILARANG DOWNLOAD TORRENT</b></font><br>
<font color="red"><b>- DILARANG SPAMING</b></font><br>
<font color="green"><b>- LOGIN SSH MAX 1 DEVICE</b></font><br>
<font color="blue"><b>क═══════क⊹⊱✫⊰⊹क═══════क</b></font><br>
<font color="purple"><b>JIKA MELANGGAR RULE DI ATAS <br> AKUN AKAN DI BAN </b></font><br>
<font color="blue"><b>क═══════क⊹⊱✫⊰⊹क═══════क</b></font><br>

<br>
<font color="blue"><b> ╔════❖•ೋ°✫°ೋ•❖════╗</b></font><br>
<font color="purple"><b>Telegram : https://t.me/kopikapal1</b></font><br>
<font color="blue"><b> ╚════❖•ೋ°✫°ೋ•❖════╝</b></font><br>
BANNER_HTML

if grep -q "^Banner" /etc/ssh/sshd_config; then
    sed -i "s|^Banner.*|Banner /etc/ssh/banner|" /etc/ssh/sshd_config
elif grep -q "^#Banner" /etc/ssh/sshd_config; then
    sed -i "s|^#Banner.*|Banner /etc/ssh/banner|" /etc/ssh/sshd_config
else
    echo "Banner /etc/ssh/banner" >> /etc/ssh/sshd_config
fi

echo "[*] Memulai OpenSSH Server di Port 22..."
/usr/sbin/sshd

echo "[*] Membuat konfigurasi Stunnel tunggal di Port $MAIN_PORT..."
cat << STUNNEL_CONF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel.pid
foreground = yes
debug = 4

[ssh-ssl]
accept = 0.0.0.0:$MAIN_PORT
connect = 127.0.0.1:22
cert = /etc/stunnel/stunnel.pem
STUNNEL_CONF

echo "[*] Memulai Stunnel..."
exec stunnel /etc/stunnel/stunnel.conf
