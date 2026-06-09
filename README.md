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

## Observabilité

### Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/health` | Etat API + DB + version |
| `GET /api/ready` | Readiness (utilisé par le healthcheck Compose) |

### Logs JSON structurés

Chaque requête produit une ligne JSON avec : `level`, `method`, `path`, `status`, `duration_ms`, `request_id`, `timestamp`.

Les niveaux utilisés : `debug` / `info` / `warn` (4xx) / `error` (5xx) / `fatal`.

Le champ `request_id` est propagé dans le header `X-Request-Id` pour tracer une requête de bout en bout.

Les données sensibles (`password`, `secret`, `token`, `key`, `database_url`) sont automatiquement masquées par `***` dans tous les logs.

### Centralisation des logs en production

En production, les logs JSON seraient centralisés via :
- **ELK Stack** (Elasticsearch + Logstash + Kibana) ou **Loki + Grafana**
- Driver Docker `fluentd` ou `syslog` à la place de `json-file`
- Alerting sur les niveaux `error` et `fatal`

### Tableau de suivi incident

| Symptome | Heure | Cause | Commande diagnostic | Resultat |
|----------|-------|-------|---------------------|---------|
| `/api/products` renvoie 500 | T+0 | Route cassee intentionnellement | `docker compose logs --tail=50 api` | Erreur visible dans logs |
| Test Jest rouge | T+1 | `npm test` echoue sur products | `npm test` | 2 tests fails |
| Rollback image v1.0.0 | T+5 | `bash scripts/rollback.sh v1.0.0` | `curl /api/products` | 200 OK |
| Tests verts apres rollback | T+6 | Version stable restauree | `npm test` | 7/7 passed |

## Diagnostic rapide

```bash
docker compose ps
docker compose logs --tail=100 api
curl http://localhost:8080/api/health
curl http://localhost:8080/api/ready
docker inspect shoplite_api
```
