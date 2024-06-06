#!/bin/bash

# mounting the usb device

block detect | uci import fstab
uci set fstab.@mount[0].enabled='1'
uci set fstab.@global[0].anon_mount='1'
uci commit fstab
/etc/init.d/fstab boot
unmount /mnt/sda1
[ -d /mnt/sda1 ] || mkdir -p /mnt/sda1; mount /dev/sda1 /mnt/sda1

# configuring package (minidlna)

IP=$(ip r | awk '/src/ {print $NF; exit}')
FILE="/etc/config/minidlna"
NEW_PRESENTATION_URL="http://${IP}:8200"
directory="/mnt/sda1/video"
interface=$(cat /etc/config/wireless | grep ifname | cut -d"'" -f2 | tr '\n' ',' | sed 's/,$//')
sed -i "s|option presentation_url '.*'|option presentation_url '$NEW_PRESENTATION_URL'|" "$FILE"
sed -i "s|list media_dir '.*'|list media_dir '$directory'|" "$FILE"
sed -i "s|option interface '.*'|option interface '$interface'|" "$FILE"

# JSON for the movies data

start_number=22
echo "[" > /www/stream/movies.json
for file in "$directory"/*; do
    if [ -f "$file" ]; then
        filename=$(basename -- "$file")
        filename_noext="${filename%.*}"
        url="http://${IP}:8200/MediaItems/$start_number.mp4"
        start_number=$((start_number + 1))
        echo "  {" >> /www/stream/movies.json
        echo "    \"name\": \"$filename_noext\"," >> /www/stream/movies.json
        echo "    \"url\": \"$url\"" >> /www/stream/movies.json
        echo "  }," >> /www/stream/movies.json
    fi
done
sed -i '$ s/,$//' /www/stream/movies.json
echo "]" >> /www/stream/movies.json

# start the server

/etc/init.d/uhttpd restart
/etc/init.d/minidlna restart

# configuring DNS

echo '192.168.168.1 library.qntmnet.com' >> /etc/qntm_hosts
/etc/init.d/dnsmasq restart
iptables -w -t nat -I PREROUTING -p tcp -m tcp --dport 80 -d 192.168.168.1 -j DNAT --to ${IP}:8300