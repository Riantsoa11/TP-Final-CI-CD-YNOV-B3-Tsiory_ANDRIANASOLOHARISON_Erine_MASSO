#!/bin/sh
set -eu

BACKUP_DIR="${BACKUP_DIR:-./backups}"
DB_CONTAINER="${DB_CONTAINER:-shoplite_db}"
POSTGRES_USER="${POSTGRES_USER:-shoplite}"
POSTGRES_DB="${POSTGRES_DB:-shoplite}"
RETENTION="${RETENTION:-7}"

mkdir -p "$BACKUP_DIR"

FILENAME="backup-$(date +%Y%m%d-%H%M%S).sql"
FILEPATH="${BACKUP_DIR}/${FILENAME}"

echo "[backup] DB       : ${POSTGRES_DB}"
echo "[backup] Container: ${DB_CONTAINER}"
echo "[backup] Fichier  : ${FILEPATH}"

docker exec "$DB_CONTAINER" pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "$FILEPATH"

SIZE=$(wc -c < "$FILEPATH")
echo "[backup] Taille   : ${SIZE} octets"

# Retention : garder les N derniers dumps
COUNT=$(ls -1t "${BACKUP_DIR}"/backup-*.sql 2>/dev/null | wc -l | tr -d ' ')
if [ "$COUNT" -gt "$RETENTION" ]; then
  REMOVE=$((COUNT - RETENTION))
  ls -1t "${BACKUP_DIR}"/backup-*.sql | tail -n "$REMOVE" | xargs rm -f
  echo "[backup] Retention: suppression de ${REMOVE} ancien(s) dump(s) (max ${RETENTION})"
fi

echo "[backup] Backups disponibles :"
ls -lh "${BACKUP_DIR}"/backup-*.sql 2>/dev/null || echo "  aucun"
echo "[backup] OK"
