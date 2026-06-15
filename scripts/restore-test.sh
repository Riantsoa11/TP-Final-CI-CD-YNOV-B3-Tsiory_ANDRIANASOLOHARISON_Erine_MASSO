#!/bin/sh
set -eu

# ============================================================
# restore-test.sh — Tester la restauration d'un dump
# ============================================================
#
# Ce script vérifie qu'un dump créé par backup.sh est VALIDE
# et RESTAURABLE, en le restaurant dans une base TEMPORAIRE
# (donc sans toucher à la vraie base de données).
#
# Pourquoi une base temporaire ?
#   Si on restaurait directement dans "shoplite", on écraserait
#   les données actuelles. Une base temporaire permet de tester
#   "est-ce que ce dump fonctionne ?" sans aucun risque.
#
# Usage :
#   ./scripts/restore-test.sh                       (prend le dump le plus récent)
#   ./scripts/restore-test.sh backups/shoplite_xxx.sql  (dump spécifique)
# ============================================================

CONTAINER="${DB_CONTAINER:-shoplite_db}"
DB_USER="${POSTGRES_USER:-shoplite}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"
TEST_DB="shoplite_restore_test"

# --- Choix du fichier de dump ---
# Si un argument est fourni, on l'utilise. Sinon, on prend
# automatiquement le dump le plus récent du dossier backups/.
if [ $# -ge 1 ]; then
  DUMP_FILE="$1"
else
  DUMP_FILE=$(ls -1t "${BACKUP_DIR}"/shoplite_*.sql 2>/dev/null | head -n 1)
fi

if [ -z "${DUMP_FILE:-}" ] || [ ! -f "$DUMP_FILE" ]; then
  echo "Aucun fichier de dump trouvé. Lance d'abord ./scripts/backup.sh"
  exit 1
fi

echo "Test de restauration du dump : $DUMP_FILE"

# --- Étape 1 : créer une base temporaire propre ---
# On supprime d'abord l'ancienne base de test si elle existe
# (au cas où un précédent test a échoué et laissé des résidus),
# puis on en crée une nouvelle vide.
echo "Création de la base temporaire '${TEST_DB}'..."
docker exec -t "$CONTAINER" psql -U "$DB_USER" -d postgres -c "DROP DATABASE IF EXISTS ${TEST_DB};"
docker exec -t "$CONTAINER" psql -U "$DB_USER" -d postgres -c "CREATE DATABASE ${TEST_DB};"

# --- Étape 2 : restaurer le dump dans cette base temporaire ---
# On envoie le contenu du fichier SQL via stdin au conteneur
# ("docker exec -i" = mode interactif, nécessaire pour lire stdin).
echo "Restauration du dump dans '${TEST_DB}'..."
docker exec -i "$CONTAINER" psql -U "$DB_USER" -d "$TEST_DB" < "$DUMP_FILE" > /dev/null

# --- Étape 3 : vérifier que les données sont bien là ---
# On compte le nombre de lignes dans la table "products".
PRODUCT_COUNT=$(docker exec -t "$CONTAINER" psql -U "$DB_USER" -d "$TEST_DB" -tAc "SELECT COUNT(*) FROM products;" | tr -d '[:space:]')

echo "Nombre de produits restaurés : $PRODUCT_COUNT"

if [ "$PRODUCT_COUNT" -gt 0 ]; then
  echo "Restauration réussie : le dump est valide et restaurable."
else
  echo "ERREUR : la table 'products' est vide après restauration."
  EXIT_CODE=1
fi

# --- Étape 4 : nettoyage ---
# On supprime la base temporaire : elle ne servait qu'au test,
# on ne veut pas la laisser traîner.
echo "Nettoyage de la base temporaire '${TEST_DB}'..."
docker exec -t "$CONTAINER" psql -U "$DB_USER" -d postgres -c "DROP DATABASE IF EXISTS ${TEST_DB};"

exit "${EXIT_CODE:-0}"