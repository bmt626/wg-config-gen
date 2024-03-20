#! /bin/bash

if ! command -v wg &> /dev/null
then
    echo "wg could not be found"
    echo "Ensure that wireguard is installed before use - sudo apt install wireguard"
    exit 1
fi

if ! command -v qrencode &> /dev/null
then
    echo "qrencode could not be found"
    echo "Ensure that qrencode is installed before use - sudo apt install qrencode"
    exit 2
fi

if [[ $# -ne 1 ]]; then
    echo "please supply the name of device to generate a config for"
    echo "usage: wireguard_qr_conrig_gen.sh my_iphone"
    exit 3
fi

umask 077
echo "Creating privatekey for $1"
wg genkey > /tmp/$1_privatekey

echo "Creating publickey for $1"
wg pubkey < /tmp/$1_privatekey > /tmp/$1_publickey

privkey=$(cat /tmp/$1_privatekey)
pubkey=$(cat /tmp/$1_publickey)

read -p "Enter client addess /netmask (172.16.16.0/24): " netaddress
read -p "Enter DNS (8.8.8.8,1.1.1.1): " dns
dns="${dns:=8.8.8.8,1.1.1.1}"
read -p "Enter wireguard servers publickey: " wgpubkey
read -p "Enter allowed IPs (0.0.0.0/0 for full tunnel): " allowedip
allowedip="${allowedip:=0.0.0.0/0}"
read -p "Enter wireguard server endpoint (IP/HOSTNAME:PORT): " endpoint

echo "[Interface]" >> /tmp/$1.conf
echo "PrivateKey = $pubkey" >> /tmp/$1.conf
echo "Address = $netaddress" >> /tmp/$1.conf
echo "DNS = $dns" >> /tmp/$1.conf
echo "" >> /tmp/$1.conf
echo "[Peer]" >> /tmp/$1.conf
echo "PublicKey = $wgpubkey" >> /tmp/$1.conf
echo "AllowedIPs = $allowedip" >> /tmp/$1.conf
echo "Endpoint = $endpoint" >> /tmp/$1.conf

# PersistentKeepalive = 15
# PresharedKey = {MY_PRE_SHARED_KEY}
echo "Saving QR Code to /tmp/$1.png"
qrencode -t png -o /tmp/$1.png -r /tmp/$1.conf
echo "Here is your wireguard config qrcode"
qrencode -t ansiutf8 < /tmp/$1.conf