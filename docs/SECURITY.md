# Sécurité DevSecOps — ShopLite

## Checklist sécurité

### Docker & Image

- [x] Image de base officielle (`node:20-alpine`, `postgres:16-alpine`, `nginx:1.27-alpine`)
- [x] Build multi-stage : seul le runtime final est dans l'image de production
- [x] `USER node` — processus non-root dans le conteneur API
- [x] `npm ci --omit=dev` — dépendances de développement exclues de l'image
- [x] `npm cache clean --force` — pas de cache npm dans l'image finale
- [x] `HEALTHCHECK` sur `/ready` — redémarrage automatique si l'API ne répond plus
- [x] `.dockerignore` — `node_modules`, `.env`, `coverage`, `tests` exclus du build context
- [x] Scan Trivy en CI sur chaque build (CVE CRITICAL + HIGH)

### Secrets & Configuration

- [x] Variables sensibles dans `.env` (jamais committées — dans `.gitignore`)
- [x] GitHub Secrets par environnement (staging / production)
- [x] Logs : sanitisation des champs sensibles (`password`, `token`, `key`, `authorization`)
- [x] Pas de credentials hardcodés dans le code source
- [ ] Rotation des secrets tous les 90 jours (à planifier)

### API & Application

- [x] Validation des entrées utilisateur (`express` + typage des paramètres)
- [x] Pas d'exposition des stack traces en production (`NODE_ENV=production`)
- [x] Header `X-Request-Id` pour la traçabilité des requêtes
- [x] Endpoint `/health` et `/ready` sans données sensibles
- [x] `npm audit` à chaque CI — bloquant au niveau `high`

### Infrastructure

- [x] Réseau Docker isolé (`shoplite_net`) — pas d'exposition directe des services internes
- [x] Port DB (`5432`) exposé uniquement en développement local
- [x] Proxy Nginx devant l'API — pas d'exposition directe du port 3000
- [x] Logs avec rotation (`max-size: 10m`, `max-file: 5`) — pas d'accumulation disque

### CI/CD Pipeline

- [x] Trivy scan image Docker (CRITICAL + HIGH) à chaque build
- [x] Trivy scan filesystem (secrets + misconfigurations)
- [x] Rapport SARIF uploadé dans l'onglet Security de GitHub
- [x] Environnement `production` avec approbation manuelle obligatoire
- [x] `npm audit --audit-level=high` bloquant en CI

---

## Classification des risques

| # | Risque | Composant | Probabilité | Impact | Sévérité | Mitigation |
|---|--------|-----------|-------------|--------|----------|------------|
| R1 | CVE dans `node:20-alpine` | Docker image | Moyenne | Élevé | **HIGH** | Trivy scan CI + rebuild régulier |
| R2 | Injection SQL | API `/products` | Faible | Critique | **HIGH** | Requêtes paramétrées (pas de concaténation) |
| R3 | Fuite de secrets dans les logs | API middleware | Faible | Critique | **HIGH** | Sanitisation dans `log.js` |
| R4 | Secrets exposés dans le repo | Git | Très faible | Critique | **CRITICAL** | `.gitignore` + Trivy secret scan |
| R5 | Déploiement non approuvé en prod | CI/CD | Faible | Élevé | **HIGH** | Environment protection + reviewer obligatoire |
| R6 | Perte de données PostgreSQL | Database | Faible | Critique | **HIGH** | Backup quotidien + restore-test automatisé |
| R7 | Conteneur root compromis | Docker | Faible | Élevé | **MEDIUM** | `USER node` non-root dans Dockerfile |
| R8 | Accumulation de logs disque | Infrastructure | Moyenne | Moyen | **MEDIUM** | Rotation json-file (10m / 5 fichiers) |
| R9 | Dépendances npm vulnérables | API packages | Moyenne | Élevé | **HIGH** | `npm audit` + Trivy library scan en CI |
| R10 | Rollback impossible si pas de tag | Operations | Faible | Élevé | **HIGH** | Tag obligatoire avant tout déploiement prod |

### Légende sévérité

| Sévérité | Probabilité × Impact | Action |
|----------|----------------------|--------|
| CRITICAL | Très faible × Critique ou Faible × Critique | Corriger immédiatement avant tout déploiement |
| HIGH | Faible × Élevé ou Moyenne × Élevé | Corriger dans le sprint en cours |
| MEDIUM | Faible × Moyen ou Moyenne × Moyen | Planifier dans le backlog |
| LOW | Très faible × Faible | Surveiller, pas d'action urgente |

---

## Processus de gestion des vulnérabilités

1. **Détection** : Trivy s'exécute à chaque push sur `feature/**`, `develop`, `main`
2. **Triage** : Les CVE CRITICAL/HIGH bloquent le rapport SARIF (onglet Security GitHub)
3. **Correction** :
   - Rebuild avec image de base mise à jour : `docker build --no-cache`
   - Mise à jour dépendance : `npm update <package>` + commit + CI
4. **Acceptation** : Si pas de correctif disponible, ajouter le CVE dans `.trivyignore` avec justification et date
5. **Revue** : Relire `.trivyignore` tous les 30 jours

---

## Commandes utiles

```bash
# Scan local de l'image API
docker build -t shoplite-api:scan ./api
trivy image --severity CRITICAL,HIGH shoplite-api:scan

# Scan du filesystem (secrets + misconfigurations)
trivy fs --scanners misconfig,secret .

# Audit npm
cd api && npm audit --audit-level=high

# Vérifier les variables d'environnement exposées
docker inspect shoplite_api | grep -i env
```
