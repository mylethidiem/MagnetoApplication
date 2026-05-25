# Magento 2 on AWS — Docker Stack

Magento 2 deployed on AWS EC2 (t3.micro, Debian 12) using Docker Compose.

---

## Stack

| Service | Image | Role |
|---|---|---|
| NGINX | nginx:1.26-bookworm | Reverse proxy, HTTPS termination |
| Varnish | varnish:7.6 | Full page cache |
| PHP-FPM | php:8.2-fpm-bookworm | Magento application |
| MySQL | mysql:8.0 | Database |
| Redis | redis:8-alpine | Cache + Sessions |
| Elasticsearch | elasticsearch:7.17.18 | Search engine |
| phpMyAdmin | phpmyadmin:5.2.3 | Database UI |

---

## Prerequisites

- AWS EC2 — Debian 12, t3.micro, 30GB EBS
- Ports 22, 80, 443 open in Security Group
- Docker and Docker Compose installed

---

## Setup

### 1. Install Docker on EC2

```bash
sudo apt-get update && sudo apt-get install -y docker.io docker-compose-plugin git curl
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Clone the repo

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd magento2
```

### 3. Create the .env file

```bash
cp .env.example .env
```

Edit `.env` and fill in your passwords:

```
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=magento
MYSQL_USER=magento
MYSQL_PASSWORD=your_db_password
ADMIN_PASSWORD=your_admin_password
```

### 4. Generate SSL certificate

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/test.dyna.com.key \
  -out nginx/ssl/test.dyna.com.crt \
  -subj "/CN=test.dyna.com"
```

### 5. Start the stack

```bash
docker compose up --build -d
```

### 6. Install Magento

```bash
docker compose exec PHPFPM-service bin/magento setup:install \
  --base-url=https://test.dyna.com/ \
  --base-url-secure=https://test.dyna.com/ \
  --db-host=mysql-service \
  --db-name=magento \
  --db-user=magento \
  --db-password=YOUR_DB_PASSWORD \
  --search-engine=elasticsearch7 \
  --elasticsearch-host=elastic-service \
  --backend-frontname=admin \
  --admin-user=admin \
  --admin-password=YOUR_ADMIN_PASSWORD \
  --use-rewrites=1 \
  --use-secure=1 \
  --use-secure-admin=1
```

---

## Access

Add this to your local `/etc/hosts` file:

```
YOUR_EC2_IP   test.dyna.com
```

| URL | What |
|---|---|
| https://test.dyna.com | Magento storefront |
| https://test.dyna.com/admin | Magento admin panel |
| https://test.dyna.com/pma/ | phpMyAdmin |

---

## Verify Varnish Cache

Run this twice — second response should show `X-Cache: HIT`:

```bash
curl -I https://test.dyna.com --insecure
```

---

## Project Structure

```
magento2/
├── docker-compose.yaml
├── .env.example
├── nginx/
│   ├── Dockerfile
│   ├── conf.d/
│   │   └── magento.conf
│   └── ssl/              # gitignored
├── php-fpm/
│   └── Dockerfile
├── varnish/
│   ├── Dockerfile
│   └── magento.vcl
└── cron/
    └── Dockerfile
```

---

## Notes

- `.env` is gitignored — never commit real passwords
- SSL certificate is self-signed — browser will show a warning, this is expected
- Elasticsearch heap is limited to 128MB to fit within EC2 free tier RAM
