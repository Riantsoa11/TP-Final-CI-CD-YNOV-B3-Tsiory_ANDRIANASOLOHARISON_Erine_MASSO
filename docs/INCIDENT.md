# Rapport d'Incident — ShopLite v1.1.0

## Résumé

| Champ | Valeur |
|-------|--------|
| Date | 2026-06-15 |
| Sévérité | Critique |
| Impact | Route /api/products inaccessible — catalogue produits indisponible |
| Durée | ~5 minutes |
| Statut | Résolu |

## Timeline

| Heure | Action | Responsable | Résultat |
|-------|--------|-------------|---------|
| T+0 | Déploiement v1.1.0 avec bug table SQL | DevOps | /api/products renvoie 500 |
| T+1 | Détection : test Jest rouge sur products | QA | 2 tests échouent |
| T+2 | Analyse logs : `docker compose logs api` | DevOps | Erreur SQL "relation produits_inexistante does not exist" |
| T+3 | Vérif données : `bash scripts/backup.sh` | DBA | Backup OK, données intactes |
| T+4 | Décision rollback validée | PO | Rollback vers v1.0.0 |
| T+5 | `bash scripts/rollback.sh v1.0.0` | DevOps | API redémarrée avec image stable |
| T+6 | `git revert HEAD` + rebuild | DevOps | Code source corrigé |
| T+7 | Smoke tests + `npm test` | QA | 9/9 tests verts |
| T+8 | Confirmation données PostgreSQL intactes | DBA | 3 produits présents |

## Diagnostic

```bash
# Commandes utilisées pour diagnostiquer
docker compose logs --tail=50 api
curl http://localhost:8080/api/products
curl http://localhost:8080/api/health
docker compose ps
git log --oneline -5
```

Erreur observée dans les logs :
```json
{"level":"error","message":"request","status":500,"path":"/products","request_id":"..."}
```

Cause racine : nom de table incorrect `produits_inexistante` au lieu de `products` dans la query SQL.

## Actions de correction

1. **Rollback image** : `bash scripts/rollback.sh v1.0.0` — service restauré immédiatement
2. **Revert git** : `git revert HEAD` — code source corrigé
3. **Rebuild image** : `docker compose up -d --build api` — image v1.0.0 reconstruite proprement

## Données PostgreSQL

Les données n'ont pas été perdues. Le rollback n'a pas touché au volume `shoplite_pgdata`.
Vérification post-rollback : `curl http://localhost:8080/api/products` retourne les 3 produits.

## Prévention

- Ajouter un test d'intégration sur `/api/products` en CI (déjà fait)
- La CI bloque le déploiement si les tests échouent (`needs: [test]` dans ci.yml)
- Toujours faire un backup avant de déployer (`bash scripts/backup.sh`)
- Taguer chaque image stable pour permettre un rollback rapide
