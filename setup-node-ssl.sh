#!/bin/bash

# -----------------------------
# Node-Web Full Setup Script
# -----------------------------
# Domain: gensen.safeinr.xyz
# Node backend port: 3443
# Node frontend port: 3000
# Email for SSL: gensen@safeinr.xyz
# -----------------------------

DOMAIN="gensen.safeinr.xyz"
NODE_BACKEND_PORT=3443
NODE_FRONTEND_PORT=3000
EMAIL="gensen@safeinr.xyz"

echo "Starting full setup for $DOMAIN ..."

# 1. Update system
apt update && apt upgrade -y

# 2. Install required packages
apt install -y nginx certbot python3-certbot-nginx ufw git curl wget

# 3. Configure firewall
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow $NODE_BACKEND_PORT/tcp
ufw --force enable

# 4. Remove old config if exists
rm -f /etc/nginx/sites-enabled/$DOMAIN
rm -f /etc/nginx/sites-available/$DOMAIN

# 5. Create Nginx config
cat > /etc/nginx/sites-available/$DOMAIN <<EOL
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/html;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

    location / {
        return 301 https://\$host\$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    # SSL certificates (Certbot will fill automatically)
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    # Proxy backend (node API / signing)
    location /node/ {
        proxy_pass http://127.0.0.1:$NODE_BACKEND_PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 120s;
    }

    # Proxy frontend (node UI)
    location / {
        proxy_pass http://127.0.0.1:$NODE_FRONTEND_PORT/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_read_timeout 120s;
    }
}
EOL

# 6. Enable site and test Nginx
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

# 7. Obtain SSL with Certbot
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

# 8. Final reload of Nginx
systemctl reload nginx

echo ""
echo "------------------------------------"
echo "Setup complete!"
echo "Frontend accessible at: https://$DOMAIN/"
echo "Backend accessible at: https://$DOMAIN/node/"
echo "Node backend port on VPS: $NODE_BACKEND_PORT"
echo "Node frontend port on VPS: $NODE_FRONTEND_PORT"
echo "------------------------------------"
