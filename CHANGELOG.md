# Changelog

Toutes les modifications notables de ce projet sont documentées ici.

Format : [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/)
Versionnage : [Semantic Versioning](https://semver.org/lang/fr/)

---

## [1.1.0] — 2026-06-15

### Ajouté
- Scripts de backup PostgreSQL avec horodatage et rétention 7 fichiers (`scripts/backup.sh`)
- Script de restauration en base temporaire pour vérification (`scripts/restore-test.sh`)
- Script de rollback par image Docker taguée avec smoke tests (`scripts/rollback.sh`)
- Script de smoke tests avec retry (`scripts/smoke-test.sh`)
- Rapport d'incident complet avec timeline T+0→T+8 (`docs/INCIDENT.md`)
- Scan de sécurité Trivy en CI (image + filesystem, rapport SARIF)
- Checklist sécurité DevSecOps et classification des risques (`docs/SECURITY.md`)
- Dossier `backups/` versionné avec `.gitkeep`

### Modifié
- `docker-compose.yml` : variable `API_VERSION` pour sélectionner l'image au rollback
- `ci.yml` : ajout job `security` avec Trivy après `build-docker`

---

## [1.0.0] — 2026-06-14

### Ajouté
- API Node.js/Express avec routes `/api/products`, `/api/health`, `/api/ready`
- Base de données PostgreSQL 16 avec schéma initial (`database/init.sql`)
- Frontend statique Nginx (`frontend/`)
- Proxy Nginx avec routage `/api` → API, `/` → frontend (`infra/nginx/`)
- Build Docker multi-stage pour l'API (`api/Dockerfile`) — image non-root, HEALTHCHECK
- Dockerfiles pour base de données et proxy (sans bind mount)
- Docker Compose complet avec healthchecks, resource limits, logs json-file avec rotation
- Pipeline CI GitHub Actions : lint (ESLint + Prettier), tests matrix Node 18/20, build Docker
- Pipeline CD GitHub Actions : deploy staging (develop) + deploy production (tags v*)
- Logs structurés JSON avec niveaux et sanitisation des champs sensibles
- Middleware `request_id` avec header `X-Request-Id`
- Tests Jest avec couverture ≥ 80% et service PostgreSQL en CI
- ESLint v9 flat config + Prettier
- `.dockerignore`, `.gitignore`, `.env.example`
- Templates PR GitHub (`.github/pull_request_template.md`)

---

## [1.0.1-hotfix] — 2026-06-15 *(incident v1.1.0)*

### Corrigé
- `api/src/routes/products.js` : nom de table corrigé (`produits_inexistante` → `products`)

### Contexte
Déployé via `bash scripts/rollback.sh v1.0.0` puis `git revert` du commit fautif.
Voir `docs/INCIDENT.md` pour le rapport complet.

---

## [0.1.0] — 2026-06-01

### Ajouté
- Projet starter ShopLite (structure initiale)

[1.1.0]: https://github.com/Riantsoa11/TP-Final-CI-CD-YNOV-B3-Tsiory_ANDRIANASOLOHARISON_Erine_MASSO/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Riantsoa11/TP-Final-CI-CD-YNOV-B3-Tsiory_ANDRIANASOLOHARISON_Erine_MASSO/compare/v0.1.0...v1.0.0
[0.1.0]: https://github.com/Riantsoa11/TP-Final-CI-CD-YNOV-B3-Tsiory_ANDRIANASOLOHARISON_Erine_MASSO/releases/tag/v0.1.0
