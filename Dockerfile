FROM node:lts-alpine AS builder
# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app
# Copy the content of the project to the machine
COPY . .
RUN pnpm install
RUN pnpm build

# Multi-stage builds: runner stage
FROM node:lts-alpine AS runner
ENV NODE_ENV production

# Install necessary tools
RUN corepack enable && corepack prepare pnpm@latest --activate
RUN apk add bash

WORKDIR /app

# Copy built app
COPY --from=builder /app/.next ./.next

# Copy only necessary files to run the app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./
COPY --from=builder /app/next.config.ts ./
COPY --from=builder /app/scripts ./scripts

RUN pnpm add envinfo

RUN chmod +x /app/scripts/fly-io-start.sh

CMD ["sh", "-c", "sleep infinity"]
