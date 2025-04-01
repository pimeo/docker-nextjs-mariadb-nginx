
- [Alpcloud docker nextjs template](#alpcloud-docker-nextjs-template)
  - [Requirements](#requirements)
    - [PNPM](#pnpm)
    - [Installation](#installation)
    - [Update](#update)
  - [Getting Started](#getting-started)
    - [Pre-installed packages:](#pre-installed-packages)
  - [Start docker compose services](#start-docker-compose-services)
      - [Development server](#development-server)
  - [Deployment](#deployment)
  - [How to start develop locally](#how-to-start-develop-locally)
  - [Learn More](#learn-more)
  - [Alternative: use nginx without docker](#alternative-use-nginx-without-docker)
    - [Install Nginx](#install-nginx)
    - [Install certbot](#install-certbot)
  - [Docker bake](#docker-bake)
  - [Clean docker development environment](#clean-docker-development-environment)


# Alpcloud docker nextjs template

- Created by: bsu
- Created at: 03/27/25
- Version: 0.1.0

## Requirements

- NodeJS >=20.11.1
- PNPM >=10
- NextJS >=15
- Docker >=28.0
- Make

### PNPM 

PNPM is an alternative to NPM. It's a more robust and fast node package manager. With its help we can reduce the compilation time.

### Installation

```
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

### Update

```sh
pnpm add -g pnpm
```

## Getting Started

```sh
mkdir my-next-app && cd my-next-app
git clone https://gitlab.sixbleuets.ovh/paas-alpcloud/alpcloud-docker-nextjs.git .
make install_template
```

**Note: You can now create a gitlab repository and link it remotely.**

```sh
git remote add origin `<YOUR_REPOSITORY_REMOTE_URL>`
git push origin --all
```

### Pre-installed packages:
- [TypeScript](https://www.typescriptlang.org/docs/) - TypeScript is JavaScript with syntax for types.
- [TailwindCSS](https://tailwindcss.com/docs) - A utility-first CSS framework packed with classes that can be composed to build any design, directly in your markup.
- [Drizzle ORM](https://orm.drizzle.team/docs) - Drizzle ORM is a headless TypeScript ORM with a head
- [Zod](https://zod.dev/) - TypeScript-first schema validation with static type inference

## Start docker compose services

#### Development server

```sh
docker compose -f docker-compose.dev.yml up --build
```

Access to the project via `http://localhost:3000` (application) or `http://localhost` (nginx proxy pass server)

You can edit the codebase and will see the results without refreshing.

## Deployment

```sh
docker compose down ## Required because we need to destroy entirely services
# docker compose -f docker-compose.prod.yml up --build
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml up -d
```

It's recommended to not use the `--no-cache` argument when building the docker images. It forces the webserver target to fetch and rebuilt once again the next application sources before copy to the `/var/www/html`. Consequently, the BUILD_ID from the app image will be different from the webserver image.

Access to the project via `http://localhost` (nginx proxy pass server)

```sh
docker compose -f docker-compose.prod.yml build next_app
docker compose -f docker-compose.prod.yml up --no-deps -d next_app
```

## How to start develop locally

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev # preferred
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!


## Alternative: use nginx without docker

### Install Nginx 

```sh
sudo apt update
sudo apt nginx

git clone <your_app_repository_url> <your_app_directory>
cd your_app_directory
pnpm install
pnpm run build
ppm install -g pm2
pm2 start npm --name "your-app-name" --interpreter bash -- start
pm2 show your-app-name

sudo nano /etc/nginx/sites-available/your-app-name.com

# server {
#     listen 80;
#     server_name your-domain-name.com www.your-domain-name.com;
#     location / {
#         proxy_pass http://localhost:3000;
#         proxy_set_header Host $host;
#         proxy_set_header X-Real-IP $remote_addr;
#     }

#     # Serve any static assets with NGINX
#     location /_next/static {
#         alias /home/ubuntu/PROJECT_FOLDER/.next/static;
#         add_header Cache-Control "public, max-age=3600, immutable";
#     }
# }

sudo ln -s /etc/nginx/sites-available/your-app-name.com /etc/nginx/sites-enabled/ 
sudo systemctl restart nginx
```

### Install certbot

```sh
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain-name.com -d www.your-domain-name.com

sudo nano /etc/nginx/sites-available/your-app-name.com 

# server {
#     listen 80;
#     server_name your-domain-name.com www.your-domain-name.com;
#     return 301 https://$host$request_uri;
# }

# server {
#     listen 443 ssl;
#     server_name your-domain-name.com www.your-domain-name.com;

#     ssl_certificate /etc/letsencrypt/live/your-domain-name.com/fullchain.pem;
#     ssl_certificate_key /etc/letsencrypt/live/your-domain-name.com/privkey.pem;

#     location / {
#         proxy_pass http://localhost:3000;
#         proxy_set_header Host $host;
#         proxy_set_header X-Real-IP $remote_addr;
#     }
#     location /_next/static/ {
#         alias /var/www/your-nextjs-app/out/_next/static/;
#         expires 1y;
#         access_log off;
#     }

#     location /static/ {
#         alias /var/www/your-nextjs-app/out/static/;
#         expires 1y;
#         access_log off;
#     }
# }

sudo systemctl restart nginx 
git pull
npm run build
pm2 restart your-app-name
```


## Docker bake
- [docker buildx build](https://docs.docker.com/reference/cli/docker/buildx/build/)

```sh
# Show configurations
docker buildx bake --file docker-bake.prod.hcl --file .env --print

# Build images
docker buildx bake --print --file docker-bake.prod.hcl --file .env
```

## Clean docker development environment

```sh
docker image ls
docker image prune
docker image rm my_next_app-webserver
docker image rm my_next_app-next_app
docker compose -f docker-compose.prod.yml build --no-cache
```