# Matrice RACI — ShopLite

## Légende

| Lettre | Rôle | Description |
|--------|------|-------------|
| **R** | Responsible | Réalise la tâche |
| **A** | Accountable | Valide et est responsable du résultat |
| **C** | Consulted | Consulté avant/pendant (dialogue bidirectionnel) |
| **I** | Informed | Informé du résultat (sens unique) |

## Acteurs

| Sigle | Rôle |
|-------|------|
| **DEV** | Développeur (Tsiory / Erine) |
| **OPS** | Ingénieur DevOps |
| **QA** | Responsable Qualité / Tests |
| **PO** | Product Owner |
| **SECU** | Responsable Sécurité |

---

## Matrice

### Développement

| Activité | DEV | OPS | QA | PO | SECU |
|----------|-----|-----|----|----|------|
| Écriture du code applicatif | **R/A** | I | C | I | I |
| Écriture des tests unitaires | **R** | I | **A** | I | I |
| Écriture des tests d'intégration | **R** | C | **A** | I | I |
| Code review Pull Request | **R** | C | **C** | I | C |
| Merge vers `develop` | **R/A** | I | I | I | I |

### Infrastructure & Docker

| Activité | DEV | OPS | QA | PO | SECU |
|----------|-----|-----|----|----|------|
| Rédaction des Dockerfiles | C | **R/A** | I | I | C |
| Configuration Docker Compose | C | **R/A** | I | I | C |
| Configuration Nginx (proxy) | I | **R/A** | I | I | I |
| Gestion des volumes et réseaux | I | **R/A** | I | I | I |
| Exposition des ports | C | **R** | I | I | **A** |

### CI/CD

| Activité | DEV | OPS | QA | PO | SECU |
|----------|-----|-----|----|----|------|
| Rédaction pipeline CI (GitHub Actions) | C | **R/A** | C | I | C |
| Rédaction pipeline CD (staging/prod) | C | **R/A** | I | C | C |
| Configuration des environments GitHub | I | **R** | I | **A** | C |
| Création des GitHub Secrets | I | **R/A** | I | I | C |
| Approbation déploiement production | I | R | I | **A** | C |
| Merge `develop` → `main` (release) | C | **R** | C | **A** | I |

### Sécurité

| Activité | DEV | OPS | QA | PO | SECU |
|----------|-----|-----|----|----|------|
| Scan Trivy images Docker | I | **R** | I | I | **A** |
| Traitement des CVE détectées | C | **R** | I | I | **A** |
| Audit des dépendances (`npm audit`) | **R** | I | C | I | **A** |
| Gestion des secrets (rotation) | I | **R** | I | I | **A** |
| Rédaction checklist sécurité | C | **R** | C | I | **A** |

### Backup & Rollback

| Activité | DEV | OPS | QA | PO | SECU |
|----------|-----|-----|----|----|------|
| Exécution backup avant déploiement | I | **R/A** | I | I | I |
| Test de restauration (`restore-test.sh`) | I | **R/A** | C | I | I |
| Décision de rollback | C | R | C | **A** | I |
| Exécution du rollback (`rollback.sh`) | I | **R/A** | I | I | I |
| Validation post-rollback (smoke tests) | I | R | **A** | I | I |
| Rédaction rapport d'incident | C | **R** | C | **A** | I |

### Monitoring & Observabilité

| Activité | DEV | OPS | QA | PO | SECU |
|----------|-----|-----|----|----|------|
| Implémentation des logs structurés | **R/A** | C | I | I | C |
| Configuration des endpoints `/health` `/ready` | **R/A** | C | C | I | I |
| Surveillance des logs en production | I | **R/A** | I | I | I |
| Analyse des logs lors d'un incident | C | **R/A** | C | I | C |

### Documentation

| Activité | DEV | OPS | QA | PO | SECU |
|----------|-----|-----|----|----|------|
| README et documentation utilisateur | **R/A** | C | C | C | I |
| CHANGELOG | **R** | C | I | **A** | I |
| CONTRIBUTING | C | **R/A** | C | I | I |
| Architecture (ARCHITECTURE.md) | C | **R/A** | I | C | I |
| Rapport d'incident (INCIDENT.md) | C | **R/A** | C | **A** | C |
| Indicateurs DORA (DORA.md) | I | **R/A** | C | C | I |
| Matrice RACI (ce document) | C | **R/A** | I | C | I |
