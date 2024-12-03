#!/bin/bash

# Local SSH Connection Manager
# Bu script yerel ağda SSH bağlantısını yönetir

# Renk kodları
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Root kontrolü
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Bu script root yetkisi gerektirmektedir.${NC}"
    echo "Lütfen 'sudo' ile çalıştırın."
    exit 1
fi

# SSH servisinin varlığını kontrol et
if ! command -v sshd &> /dev/null; then
    echo -e "${RED}SSH servisi bulunamadı!${NC}"
    echo "OpenSSH'ı yüklemek için: sudo apt-get install openssh-server"
    exit 1
fi

# Yerel IP adresini al
LOCAL_IP=$(ip route get 1 | awk '{print $7;exit}')

# Temizlik fonksiyonu
cleanup() {
    echo -e "\n${BLUE}Script kapatılıyor...${NC}"
    # Aktif SSH bağlantılarını sonlandır
    pkill -f sshd
    # SSH servisini durdur
    systemctl stop ssh
    echo -e "${GREEN}SSH servisi durduruldu ve tüm bağlantılar sonlandırıldı.${NC}"
    exit 0
}

# CTRL+C sinyalini yakala
trap cleanup SIGINT

# SSH servisini başlat
systemctl start ssh

# SSH servisinin durumunu kontrol et
if ! systemctl is-active --quiet ssh; then
    echo -e "${RED}SSH servisi başlatılamadı!${NC}"
    exit 1
fi

# Güvenlik ayarları - sadece yerel ağa izin ver
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
echo "ListenAddress ${LOCAL_IP}" >> /etc/ssh/sshd_config
systemctl restart ssh

echo -e "${GREEN}SSH Bağlantı Yöneticisi aktif!${NC}"
echo -e "${BLUE}Bu cihaza bağlanmak için:${NC}"
echo -e "1. Diğer bilgisayarınızdan aşağıdaki komutu kullanın:"
echo -e "${GREEN}   ssh $(whoami)@${LOCAL_IP}${NC}"
echo -e "2. Şifrenizi girmeniz istenecektir."
echo -e "\n${BLUE}Scripti durdurmak için CTRL+C tuşlarına basın.${NC}"

# Scripti açık tut
while true; do
    sleep 1
done
