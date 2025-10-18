# Node-Web

This repository contains a **one-click setup script** for deploying a crypto node on a VPS with SSL. It installs Nginx, configures your node to run on a subdomain, obtains a Let's Encrypt certificate, and sets up firewall rules.

---

## Features

- Automatic installation of Nginx and Certbot
- Configure Nginx to proxy your node on localhost
- Obtain a free Let's Encrypt SSL certificate for your domain/subdomain
- Firewall configuration for HTTP, HTTPS, and your node port
- Easy to reuse and modify

---

## Prerequisites

- VPS running Ubuntu/Debian
- Root or sudo access
- Domain name (e.g., `safeinr.xyz`) with a subdomain pointing to your VPS
- Node running locally on a specific port (default 3443)
- Git installed on your local machine (optional for cloning)

---

## Setup Instructions

1. Clone the repository on your VPS:

```bash
git clone https://github.com/askshreesen/Node-Web.git
cd Node-Web
