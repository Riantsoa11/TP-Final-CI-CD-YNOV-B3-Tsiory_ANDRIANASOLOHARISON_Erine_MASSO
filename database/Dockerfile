FROM postgres:16-alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=dev

LABEL org.opencontainers.image.title="ShopLite Database" \
      org.opencontainers.image.description="PostgreSQL 16 avec schema initial ShopLite" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/Riantsoa11/TP-Final-CI-CD-YNOV-B3-Tsiory_ANDRIANASOLOHARISON_Erine_MASSO" \
      org.opencontainers.image.authors="Tsiory Andrianasoloharison, Erine Masso" \
      org.opencontainers.image.licenses="MIT"

COPY init.sql /docker-entrypoint-initdb.d/init.sql
