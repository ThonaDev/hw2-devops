#!/bin/bash

DOMAIN_NAME="$1"
SERVICE_PORT="$2"

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: only root|sudoers able to run it ⚠️"
    echo "Usage: sudo bash $0"
    exit 1
fi

if [ -z "${DOMAIN_NAME}" ] || [ -z "${SERVICE_PORT}" ]; then
    echo "SERVICE PORT and DOMAIN NAME is required ⚠️"
    echo "Usage: sudo bash $0 <domain_name> <port>"
    exit 1
fi

echo "1. Generate reverse proxy config file "
tee "/etc/nginx/conf.d/${DOMAIN_NAME}.conf"<< EOF



server {
    listen 80;
    server_name ${DOMAIN_NAME};

    location / {
        proxy_pass http://localhost:${SERVICE_PORT};
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}  


EOF


set -x
echo "Testing the configurationi....."
sudo nginx -t
sudo systemctl restart nginx
#sudo nginx -s reload

# add https for the service
sudo certbot --nginx -d "${DOMAIN_NAME}"
set +x
echo "==================| CONGRATULATIONS |==================="
