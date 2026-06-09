# ShopLite — TP Final DevOps

[![CI](https://github.com/Riantsoa11/TP-Final-CI-CD-YNOV-B3-Tsiory_ANDRIANASOLOHARISON_Erine_MASSO/actions/workflows/ci.yml/badge.svg)](https://github.com/Riantsoa11/TP-Final-CI-CD-YNOV-B3-Tsiory_ANDRIANASOLOHARISON_Erine_MASSO/actions/workflows/ci.yml)
[![CD](https://github.com/Riantsoa11/TP-Final-CI-CD-YNOV-B3-Tsiory_ANDRIANASOLOHARISON_Erine_MASSO/actions/workflows/cd.yml/badge.svg)](https://github.com/Riantsoa11/TP-Final-CI-CD-YNOV-B3-Tsiory_ANDRIANASOLOHARISON_Erine_MASSO/actions/workflows/cd.yml)

Mini application e-commerce industrialisée : API Node.js, frontend statique, PostgreSQL, Docker, CI/CD GitHub Actions.

## Lancement rapide

```bash
cp .env.example .env
docker compose up -d --build
```

| URL | Description |
|-----|-------------|
| http://localhost:8080 | Frontend |
| http://localhost:8080/api/health | Health check |
| http://localhost:8080/api/products | Liste produits |
| http://localhost:8081 | Staging (port distinct) |

## Environnements

| Env | Port | Branche / Tag | Déploiement |
|-----|------|---------------|-------------|
| dev | 8080 | toutes branches | manuel |
| staging | 8081 | `develop` | automatique (CD) |
| production | 8080 | tag `v*` | manuel approuvé (CD) |

## Tests

```bash
cd api
npm install
npm test
npm run lint
npm run format:check
```

## Docker

```bash
# Build local
docker build -t shoplite-api:v1.0.0 ./api
docker images shoplite-api

# Staging
docker compose -f docker-compose.yml -f docker-compose.staging.yml up -d --build

# Arreter (sans supprimer les donnees)
docker compose down
```

## CI/CD

- **CI** : lint + tests (Node 18 & 20) + build Docker — declenche sur push et PR
- **CD** : deploy staging sur `develop`, deploy production sur tag `v*` avec approbation manuelle

## Branches

```
main        <- production stable (tags v*)
develop     <- integration (auto-deploy staging)
feature/*   <- nouvelles fonctionnalites
hotfix/*    <- corrections urgentes depuis main
```

## Tableau de suivi incident

| Symptome | Heure | Cause | Commande | Resultat |
|----------|-------|-------|----------|---------|
| /api/products 500 | - | - | `docker compose logs api` | - |

## Diagnostic rapide

```bash
docker compose ps
docker compose logs --tail=100 api
curl http://localhost:8080/api/health
docker inspect shoplite_api
```
