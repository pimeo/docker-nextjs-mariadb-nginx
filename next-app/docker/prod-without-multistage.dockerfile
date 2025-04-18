# syntax=docker.io/docker/dockerfile:1

# syntax=docker.io/docker/dockerfile:1

ARG NODE_VERSION="20-alpine"
ARG NGINX_VERSION="1.27.4-alpine"

FROM node:${NODE_VERSION} as next_app

WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* .npmrc* ./
# Omit --production flag for TypeScript devDependencies
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
  # Allow install without lockfile, so example works even without Node.js installed locally
  else echo "Warning: Lockfile not found. It is recommended to commit lockfiles to version control." && yarn install; \
  fi

COPY src ./src
COPY public ./public
# COPY next.config.ts .
COPY next.config.js .
COPY drizzle.config.ts .
COPY postcss.config.mjs .
COPY eslint.config.mjs .
COPY tsconfig.json .

# Environment variables must be present at build time
# https://github.com/vercel/next.js/discussions/14030
ARG NEXT_PUBLIC_APP_HOST_DOMAIN
ENV NEXT_PUBLIC_APP_HOST_DOMAIN=${NEXT_PUBLIC_APP_HOST_DOMAIN}

ARG NEXT_PUBLIC_APP_EXTERNAL_URL
ENV NEXT_PUBLIC_APP_EXTERNAL_URL=${NEXT_PUBLIC_APP_EXTERNAL_URL}
RUN echo "NEXT_PUBLIC_APP_EXTERNAL_URL: ${NEXT_PUBLIC_APP_EXTERNAL_URL}"

ARG NEXT_APP_HOST_HTTP_PORT
ENV NEXT_APP_HOST_HTTP_PORT=${NEXT_APP_HOST_HTTP_PORT}

ARG NEXT_APP_HOST_HTTPS_PORT
ENV NEXT_APP_HOST_HTTPS_PORT=${NEXT_APP_HOST_HTTPS_PORT}

ARG HOSTNAME="0.0.0.0"
ENV HOSTNAME=${HOSTNAME}

# Next.js collects completely anonymous telemetry data about general usage. Learn more here: https://nextjs.org/telemetry
# Uncomment the following line to disable telemetry at run time
ENV NEXT_TELEMETRY_DISABLED 1

# Note: Don't expose ports here, Compose will handle that for us

# Build Next.js based on the preferred package manager
RUN \
  if [ -f yarn.lock ]; then yarn build; \
  elif [ -f package-lock.json ]; then npm run build; \
  elif [ -f pnpm-lock.yaml ]; then pnpm build; \
  else npm run build; \
  fi

# Start Next.js based on the preferred package manager
CMD \
  if [ -f yarn.lock ]; then yarn start; \
  elif [ -f package-lock.json ]; then npm run start; \
  elif [ -f pnpm-lock.yaml ]; then pnpm start; \
  else npm run start; \
  fi


FROM nginx:${NGINX_VERSION} AS webserver
COPY --from=next_app /app/.next/standalone /var/www/html
COPY --from=next_app /app/.next/static /var/www/html/.next/static
COPY ./nginx-conf/nginx.conf /etc/nginx/conf.d/default.conf