# ── Stage 1: Builder ──
FROM node:20-slim AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install --omit=dev

COPY src ./src

# ── Stage 2: Production ──
FROM node:20-slim

WORKDIR /app

# Create non-root user for security
RUN groupadd -r nodeapp && useradd -r -g nodeapp nodeapp

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src       ./src
COPY --from=builder /app/package.json .

RUN chown -R nodeapp:nodeapp /app

EXPOSE 3000

ENV NODE_ENV=production
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
  CMD ["node", "-e", "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"]

USER nodeapp

CMD ["node", "src/index.js"]
