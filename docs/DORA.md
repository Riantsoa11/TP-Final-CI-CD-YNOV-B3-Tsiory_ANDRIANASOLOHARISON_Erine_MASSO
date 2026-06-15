# Indicateurs DORA — ShopLite

Les 4 métriques DORA (DevOps Research and Assessment) mesurent la performance d'une équipe DevOps.

---

## 1. Deployment Frequency (Fréquence de déploiement)

**Définition** : Combien de fois par jour/semaine l'équipe déploie en production.

**Niveau DORA** : Elite = plusieurs fois par jour | High = une fois par semaine | Medium = une fois par mois | Low = moins d'une fois par mois

| Environnement | Déclencheur | Fréquence actuelle |
|---------------|-------------|-------------------|
| Staging | Push sur `develop` | À chaque merge de feature |
| Production | Tag `v*` | À chaque release validée |

**Niveau atteint sur ce projet** : **High** — un déploiement en production par bloc de fonctionnalités (v1.0.0, v1.1.0).

**Pour atteindre Elite** : automatiser les tests de non-régression et réduire la taille des PRs pour déployer plusieurs fois par semaine.

---

## 2. Lead Time for Changes (Délai de mise en production)

**Définition** : Temps entre le premier commit d'un changement et son déploiement en production.

**Niveau DORA** : Elite = < 1 heure | High = 1 jour | Medium = 1 semaine | Low = 1 mois

| Étape | Durée estimée |
|-------|---------------|
| Développement local + tests | 30 min – 2 h |
| CI (lint + test + build + Trivy) | ~5 min |
| Review de PR | 30 min – 2 h |
| Deploy staging | ~2 min |
| Approbation production | 0 – 24 h (selon disponibilité reviewer) |
| Deploy production | ~2 min |

**Total** : ~1 h (hors attente de review)

**Niveau atteint** : **High** — le pipeline CI/CD réduit le lead time technique à quelques minutes ; le délai humain (review) est le facteur limitant.

**Pour atteindre Elite** : feature flags pour déployer sans review bloquante, trunk-based development.

---

## 3. Change Failure Rate (Taux d'échec des déploiements)

**Définition** : Pourcentage de déploiements en production qui causent un incident nécessitant un rollback ou hotfix.

**Niveau DORA** : Elite = 0–5% | High = 6–15% | Medium = 16–45% | Low = > 45%

**Données du projet** :

| Release | Résultat | Incident |
|---------|----------|----------|
| v1.0.0 | ✅ Succès | Non |
| v1.1.0 | ❌ Rollback requis | Oui — table SQL incorrecte |

**Calcul** : 1 incident / 2 déploiements = **50%** *(sur petit échantillon)*

**Niveau réel** : Low sur cet échantillon — mais représentatif d'un projet en phase d'apprentissage.

**Actions correctives mises en place** :
- Tests d'intégration sur `/api/products` en CI (bloque les bugs SQL)
- `npm audit` + Trivy en CI
- Backup obligatoire avant déploiement

**Objectif** : < 5% une fois les tests CI stabilisés.

---

## 4. Mean Time to Recovery (Temps moyen de rétablissement)

**Définition** : Temps moyen pour rétablir le service après un incident en production.

**Niveau DORA** : Elite = < 1 heure | High = < 1 jour | Medium = < 1 semaine | Low = > 1 semaine

**Incident v1.1.0 — timeline** :

| Heure | Événement |
|-------|-----------|
| T+0 | Déploiement v1.1.0 — bug détecté |
| T+1 | Détection via tests Jest |
| T+2 | Diagnostic logs Docker |
| T+3 | Backup vérifié |
| T+4 | Décision rollback |
| T+5 | `bash scripts/rollback.sh v1.0.0` — service rétabli |

**MTTR : ~5 minutes**

**Niveau atteint** : **Elite** — le script `rollback.sh` automatise l'ensemble du processus (vérification image, redémarrage, smoke tests).

**Facteurs clés** :
- Images Docker taguées par version → rollback instantané sans rebuild
- Smoke tests automatiques post-rollback
- Backup PostgreSQL préalable garantit la récupération des données

---

## Résumé des niveaux DORA

| Métrique | Valeur mesurée | Niveau DORA | Objectif |
|----------|---------------|-------------|---------|
| Deployment Frequency | ~1 fois / bloc | **High** | Elite (plusieurs/semaine) |
| Lead Time for Changes | ~1 heure | **High** | Elite (< 1 heure) |
| Change Failure Rate | 50% (2 releases) | **Low** | Elite (< 5%) |
| MTTR | ~5 minutes | **Elite** | Maintenir |

> Note : Le Change Failure Rate élevé (50%) est dû au faible nombre de releases sur ce projet de TP. En production réelle avec la CI bloquante sur les tests d'intégration, ce taux serait significativement plus bas.
