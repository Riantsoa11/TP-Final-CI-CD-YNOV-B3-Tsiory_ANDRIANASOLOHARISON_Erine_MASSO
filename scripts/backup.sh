#!/bin/sh
set -eu

# ============================================================
# backup.sh — Sauvegarde de la base PostgreSQL
# ============================================================
#
# Ce script crée un dump SQL horodaté de la base PostgreSQL
# qui tourne dans le conteneur "shoplite_db", et applique une
# politique de rétention (on ne garde que les N derniers dumps).
#
# Usage :
#   ./scripts/backup.sh
#
# Les dumps sont stockés dans backups/ à la racine du projet
# (volume monté depuis l'hôte, donc PAS perdus si le conteneur
# est supprimé).
# ============================================================

# --- Configuration (modifiable via variables d'environnement) ---
CONTAINER="${DB_CONTAINER:-shoplite_db}"
DB_NAME="${POSTGRES_DB:-shoplite}"
DB_USER="${POSTGRES_USER:-shoplite}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"
RETENTION="${BACKUP_RETENTION:-7}"

# --- Préparation ---
mkdir -p "$BACKUP_DIR"

# Nom de fichier horodaté, ex: shoplite_20260614_143000.sql
TIMESTAMP=$(date -u +"%Y%m%d_%H%M%S")
BACKUP_FILE="${BACKUP_DIR}/shoplite_${TIMESTAMP}.sql"

echo "Sauvegarde de la base '${DB_NAME}' depuis le conteneur '${CONTAINER}'..."

# pg_dump exporte le contenu de la base en SQL.
# On l'exécute À L'INTÉRIEUR du conteneur via "docker exec",
# puis on redirige la sortie vers un fichier sur l'hôte.
docker exec -t "$CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"

echo "Backup créé : $BACKUP_FILE"
echo "Taille      : $(du -h "$BACKUP_FILE" | cut -f1)"

# --- Politique de rétention ---
# On compte combien de dumps existent, du plus récent au plus ancien.
# Si on en a plus que $RETENTION, on supprime les plus vieux.
COUNT=$(ls -1 "${BACKUP_DIR}"/shoplite_*.sql 2>/dev/null | wc -l)

if [ "$COUNT" -gt "$RETENTION" ]; then
  TO_DELETE=$((COUNT - RETENTION))
  echo "Rétention : suppression des $TO_DELETE plus anciens dumps (on garde $RETENTION)."

  # "ls -1t" trie par date de modification (plus récent en premier).
  # "tail -n +X" prend tout SAUF les X premières lignes,
  # donc ici : tout sauf les $RETENTION plus récents.
  ls -1t "${BACKUP_DIR}"/shoplite_*.sql | tail -n +$((RETENTION + 1)) | while read -r old_file; do
    echo "  Suppression : $old_file"
    rm -f "$old_file"
  done
fi

echo "Dumps actuellement conservés :"
ls -1t "${BACKUP_DIR}"/shoplite_*.sql 2>/dev/null