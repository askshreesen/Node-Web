#!/bin/bash

# Variables - CHANGE these to your own settings
DOMAIN="node.safeinr.xyz"
NODE_PORT=3443
EMAIL="your-email@example.com" # For Let's Encrypt notifications

# Update system
apt update && apt upgrade -y

# Install required packages
apt install -y nginx certbot python3-certbot-nginx ufw git

# Configure firewall
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow $NODE_PORT/tcp
ufw --force enable

# Nginx configuration
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

# Enable site and reload Nginx
ln -sf $NGINX_CONF /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# Obtain SSL certificate via Certbot
certbot --nginx -d $DOMAIN --non-interactive --agree-tos -m $EMAIL

# Save script to GitHub instructions
echo "Script ready. You can save it to GitHub with:"
echo "1. git init"
echo "2. git add setup-node-ssl.sh"
echo "3. git commit -m 'Add node SSL setup script'"
echo "4. git branch -M main"
echo "5. git remote add origin <YOUR_GITHUB_REPO_URL>"
echo "6. git push -u origin main"

echo "Setup complete! Your node is now accessible at https://$DOMAIN"
