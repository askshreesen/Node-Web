#!/bin/bash

# =========================
# One-Click Node Setup Script
# Domain: gensen.safeinr.xyz
# Node Port: 3443
# Email for SSL: gensen@safeinr.xyz
# =========================

DOMAIN="gensen.safeinr.xyz"
NODE_PORT=3443
EMAIL="gensen@safeinr.xyz"

echo "Starting setup for $DOMAIN ..."

# 1. Update and install packages
apt update && apt upgrade -y
apt install -y nginx certbot python3-certbot-nginx ufw git curl wget

# 2. Configure firewall
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow $NODE_PORT/tcp
ufw --force enable

# 3. Create Nginx config
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"

cat > $NGINX_CONF <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://127.0.0.1:$NODE_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 120s;
    }
}
EOL

# 4. Enable Nginx site and reload
ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# 5. Obtain SSL certificate
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

echo ""
echo "Setup complete!"
echo "Your node is now accessible at: https://$DOMAIN"
echo "Node backend port on VPS: $NODE_PORT"
