FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

FROM node:20-alpine AS runner
WORKDIR /app

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=dev

LABEL org.opencontainers.image.title="ShopLite API" \
      org.opencontainers.image.description="API REST Node.js/Express pour ShopLite" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/Riantsoa11/TP-Final-CI-CD-YNOV-B3-Tsiory_ANDRIANASOLOHARISON_Erine_MASSO" \
      org.opencontainers.image.authors="Tsiory Andrianasoloharison, Erine Masso" \
      org.opencontainers.image.licenses="MIT"

ENV NODE_ENV=production
ENV API_PORT=3000

COPY --from=deps /app/node_modules ./node_modules
COPY src ./src

USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD wget -qO- http://127.0.0.1:3000/ready || exit 1

CMD ["node", "src/server.js"]
