# Node-Web One-Click Setup

This repository provides a **one-click setup script** to deploy your crypto node on a VPS with a secure HTTPS connection using your subdomain `gensen.safeinr.xyz`. The script installs and configures Nginx, sets up a reverse proxy for your node, obtains a free Let’s Encrypt SSL certificate, and configures firewall rules.  

---

## Features

- Automatic installation of Nginx and Certbot
- Reverse proxy configuration for your node on `localhost:3443`
- Obtain a free Let’s Encrypt SSL certificate for `gensen.safeinr.xyz`
- Firewall configuration for HTTP (80), HTTPS (443), and node port (3443)
- Easy one-line execution via `curl` or `wget`

---

## Prerequisites

- VPS running Ubuntu/Debian
- Root or sudo access
- Domain name `safeinr.xyz` with a subdomain `gensen.safeinr.xyz` pointing to your VPS IP
- Node running locally on port `3443`
- Ports 80 and 443 reachable from the internet for SSL issuance

---

## One-Click Setup

Run the following command on your VPS to install and configure everything automatically:

```bash
# Using curl
curl -sSL https://raw.githubusercontent.com/askshreesen/Node-Web/main/setup-node-ssl.sh | bash
