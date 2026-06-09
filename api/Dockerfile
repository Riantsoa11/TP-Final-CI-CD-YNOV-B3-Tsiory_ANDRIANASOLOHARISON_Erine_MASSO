FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV API_PORT=3000

COPY --from=deps /app/node_modules ./node_modules
COPY src ./src

USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/ready || exit 1

CMD ["node", "src/server.js"]
