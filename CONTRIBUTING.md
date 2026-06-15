# Guide de contribution — ShopLite

## Prérequis

- Node.js 20+
- Docker Desktop
- Git configuré avec nom et email

```bash
git config user.name "Prenom Nom"
git config user.email "email@example.com"
```

---

## Stratégie de branches (Gitflow)

```
main          ← production stable, protégée (PR obligatoire + review)
develop       ← intégration continue, base de toutes les features
feature/*     ← nouvelles fonctionnalités
hotfix/*      ← correctifs urgents sur main
```

### Règles

| Branche | Crée depuis | Merge vers | Direct push |
|---------|-------------|------------|-------------|
| `feature/*` | `develop` | `develop` | Oui |
| `hotfix/*` | `main` | `main` + `develop` | Non (PR) |
| `develop` | — | `main` | Non (PR) |
| `main` | — | — | Non (protégée) |

### Créer une branche

```bash
git checkout develop
git pull origin develop
git checkout -b feature/ma-fonctionnalite
```

---

## Conventions de commits (Conventional Commits)

Format : `<type>(<scope>): <description courte>`

| Type | Usage |
|------|-------|
| `feat` | Nouvelle fonctionnalité |
| `fix` | Correction de bug |
| `chore` | Maintenance, dépendances, config |
| `docs` | Documentation uniquement |
| `test` | Ajout ou modification de tests |
| `refactor` | Refactoring sans changement de comportement |
| `ci` | Modification pipeline CI/CD |
| `perf` | Amélioration de performance |

### Exemples valides

```
feat(api): add product search endpoint
fix(auth): correct token expiration check
chore(deps): update express to 4.19.2
docs(readme): add observability section
test(products): add integration test for 404 case
ci: add Trivy security scan job
```

### Règles

- Description en **anglais**, **minuscule**, sans point final
- 72 caractères max sur la première ligne
- Corps du message si besoin d'expliquer le **pourquoi**
- `BREAKING CHANGE:` en pied de message pour les changements cassants

---

## Workflow complet

```bash
# 1. Créer sa branche
git checkout develop && git pull origin develop
git checkout -b feature/ma-fonctionnalite

# 2. Développer + tester localement
cd api && npm test

# 3. Commiter
git add fichier1 fichier2
git commit -m "feat(scope): description courte"

# 4. Pusher
git push origin feature/ma-fonctionnalite

# 5. Ouvrir une Pull Request vers develop sur GitHub
```

---

## Pull Requests

### Checklist avant d'ouvrir une PR

- [ ] Les tests passent localement (`npm test`)
- [ ] Le lint est propre (`npm run lint && npm run format:check`)
- [ ] Le titre suit les conventions de commits
- [ ] La description explique le **pourquoi** du changement
- [ ] Les fichiers sensibles ne sont pas committés (`.env`, secrets)

### Règles de review

- Toute PR vers `main` nécessite **au minimum 1 review** approuvée
- Le CI (lint + tests + Trivy) doit être **vert** avant de merger
- Utiliser **Squash & Merge** pour `feature/*` → `develop`
- Utiliser **Merge Commit** pour `develop` → `main` (préserve l'historique)

---

## Environnement de développement local

```bash
# Copier les variables d'environnement
cp .env.example .env

# Démarrer les services
docker compose up -d

# Vérifier que l'API répond
curl http://localhost:8080/api/health

# Lancer les tests (avec DB exposée sur 5432)
cd api && npm test

# Lancer le linter
npm run lint

# Vérifier le formattage
npm run format:check

# Auto-corriger le formattage
npm run format
```

---

## Tags et releases

Les releases suivent le [Semantic Versioning](https://semver.org/) :

- `MAJOR` : changement cassant (API incompatible)
- `MINOR` : nouvelle fonctionnalité rétro-compatible
- `PATCH` : correction de bug rétro-compatible

```bash
# Créer un tag de release
git tag -a v1.2.0 -m "chore: release v1.2.0"
git push origin v1.2.0
```

Le tag `v*` déclenche automatiquement le pipeline CD vers production.
