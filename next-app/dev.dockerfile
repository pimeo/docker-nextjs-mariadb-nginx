# syntax=docker.io/docker/dockerfile:1

ARG NODE_VERSION=20-alpine
FROM node:${NODE_VERSION} AS base

WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json yarn.lock* package-lock.json* pnpm-lock.yaml* .npmrc* ./
RUN \
  if [ -f yarn.lock ]; then yarn --frozen-lockfile; \
  elif [ -f package-lock.json ]; then npm ci; \
  elif [ -f pnpm-lock.yaml ]; then corepack enable pnpm && pnpm i; \
  # Allow install without lockfile, so example works even without Node.js installed locally
  else echo "Warning: Lockfile not found. It is recommended to commit lockfiles to version control." && yarn install; \
  fi

COPY src ./src
COPY public ./public
COPY next.config.ts .
COPY drizzle.config.ts .
COPY postcss.config.mjs .
COPY eslint.config.mjs .
COPY tsconfig.json .

# Environment variables must be present at build time
# https://github.com/vercel/next.js/discussions/14030
ARG NEXT_APP_HOST_DOMAIN
ENV NEXT_APP_HOST_DOMAIN=${NEXT_APP_HOST_DOMAIN}
ARG NEXT_PUBLIC_APP_HOST_DOMAIN
ENV NEXT_PUBLIC_APP_HOST_DOMAIN=${NEXT_PUBLIC_APP_HOST_DOMAIN}

ARG NEXT_APP_HOST_HTTP_PORT
ENV NEXT_APP_HOST_HTTP_PORT=${NEXT_APP_HOST_HTTP_PORT}
ARG NEXT_APP_HOST_HTTPS_PORT
ENV NEXT_APP_HOST_HTTPS_PORT=${NEXT_APP_HOST_HTTPS_PORT}

# Next.js collects completely anonymous telemetry data about general usage. Learn more here: https://nextjs.org/telemetry
# Uncomment the following line to disable telemetry at run time
ENV NEXT_TELEMETRY_DISABLED 1

# Note: Don't expose ports here, Compose will handle that for us

# Start Next.js in development mode based on the preferred package manager
CMD \
  if [ -f yarn.lock ]; then yarn dev; \
  elif [ -f package-lock.json ]; then npm run dev; \
  elif [ -f pnpm-lock.yaml ]; then pnpm dev; \
  else npm run dev; \
  fi