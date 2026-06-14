#!/bin/sh
set -eu

BACKUP_DIR="${BACKUP_DIR:-./backups}"
DB_CONTAINER="${DB_CONTAINER:-shoplite_db}"
POSTGRES_USER="${POSTGRES_USER:-shoplite}"
TEMP_DB="shoplite_restore_test"

# Trouver le dernier backup ou utiliser celui passé en argument
if [ "${1:-}" != "" ]; then
  DUMP_FILE="$1"
else
  DUMP_FILE=$(ls -1t "${BACKUP_DIR}"/backup-*.sql 2>/dev/null | head -1 || true)
fi

if [ -z "$DUMP_FILE" ] || [ ! -f "$DUMP_FILE" ]; then
  echo "[restore-test] Aucun fichier de backup trouvé dans ${BACKUP_DIR}"
  exit 1
fi

echo "[restore-test] Fichier : ${DUMP_FILE}"
echo "[restore-test] Base temporaire : ${TEMP_DB}"

# Créer la base temporaire
docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -c "DROP DATABASE IF EXISTS ${TEMP_DB};" > /dev/null
docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -c "CREATE DATABASE ${TEMP_DB};" > /dev/null
echo "[restore-test] Base temporaire créée"

# Restaurer le dump
docker exec -i "$DB_CONTAINER" psql -U "$POSTGRES_USER" -d "$TEMP_DB" < "$DUMP_FILE" > /dev/null
echo "[restore-test] Dump restauré"

# Vérifier les données
COUNT=$(docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -d "$TEMP_DB" -t -c "SELECT COUNT(*) FROM products;" | tr -d ' \n')
echo "[restore-test] Lignes dans products : ${COUNT}"

if [ "$COUNT" -gt 0 ]; then
  echo "[restore-test] Vérification OK — données présentes"
else
  echo "[restore-test] ERREUR — aucune donnée après restauration"
  docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -c "DROP DATABASE IF EXISTS ${TEMP_DB};" > /dev/null
  exit 1
fi

# Nettoyer
docker exec "$DB_CONTAINER" psql -U "$POSTGRES_USER" -c "DROP DATABASE ${TEMP_DB};" > /dev/null
echo "[restore-test] Base temporaire supprimée"
echo "[restore-test] OK"
