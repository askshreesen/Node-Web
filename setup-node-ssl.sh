#!/bin/bash

# -----------------------------
# Node-Web VPS Setup Script
# -----------------------------
# Purpose: Setup a crypto node behind Nginx with SSL
# Domain: gensen.safeinr.xyz
# Node Port: 3443
# Email: gensen@safeinr.xyz
# -----------------------------

DOMAIN="gensen.safeinr.xyz"
NODE_PORT=3443
EMAIL="gensen@safeinr.xyz"

echo "Starting setup for $DOMAIN ..."

# 1. Update system and install required packages
apt update && apt upgrade -y
apt install -y nginx certbot python3-certbot-nginx ufw git curl wget

# 2. Configure firewall
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow $NODE_PORT/tcp
ufw --force enable

# 3. Remove any existing Nginx config for this domain
if [ -f /etc/nginx/sites-enabled/$DOMAIN ]; then
    rm -f /etc/nginx/sites-enabled/$DOMAIN
fi
if [ -f /etc/nginx/sites-available/$DOMAIN ]; then
    rm -f /etc/nginx/sites-available/$DOMAIN
fi

# 4. Create HTTP-only Nginx config (before SSL)
cat > /etc/nginx/sites-available/$DOMAIN <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    root /var/www/html;

    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }

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

# 5. Enable site and reload Nginx
ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# 6. Obtain SSL certificate using Certbot
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

# 7. Optional: Serve node on external port 3443 over HTTPS
# Uncomment below if you want HTTPS directly on 3443
# cat > /etc/nginx/sites-available/$DOMAIN <<EOL
# server {
#     listen 3443 ssl;
#     server_name $DOMAIN;
#     ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
#     ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
# 
#     location / {
#         proxy_pass http://127.0.0.1:$NODE_PORT;
#         proxy_set_header Host \$host;
#         proxy_set_header X-Real-IP \$remote_addr;
#         proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto \$scheme;
#         proxy_read_timeout 120s;
#     }
# }
# EOL
# systemctl reload nginx
# ufw allow 3443/tcp

echo ""
echo "Setup complete!"
echo "Your node is now accessible at: https://$DOMAIN"
echo "Node backend port on VPS: $NODE_PORT"
