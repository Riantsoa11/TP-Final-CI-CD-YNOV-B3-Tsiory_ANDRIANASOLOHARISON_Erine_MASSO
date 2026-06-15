#!/bin/sh
set -eu

# Usage: ./scripts/rollback.sh v1.0.0
# Revient à une image API stable sans toucher aux volumes PostgreSQL.

if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

VERSION="$1"
IMAGE_NAME="shoplite-api"
TARGET_IMAGE="${IMAGE_NAME}:${VERSION}"
CONTAINER="shoplite_api"

echo "=== Rollback vers ${TARGET_IMAGE} ==="

echo "Version actuellement déployée :"
docker inspect "$CONTAINER" --format='  {{.Config.Image}}' 2>/dev/null || echo "  (conteneur non trouvé)"

IMAGE_ID=$(docker images -q "$TARGET_IMAGE")
if [ -z "$IMAGE_ID" ]; then
  echo "ERREUR : l'image '${TARGET_IMAGE}' n'existe pas en local."
  docker images "$IMAGE_NAME"
  exit 1
fi
echo "Image cible trouvée : ${TARGET_IMAGE} (${IMAGE_ID})"

# Sauvegarde des logs avant rollback (utile pour le rapport d'incident)
mkdir -p ./logs
LOG_FILE="./logs/api_before_rollback_$(date -u +%Y%m%d_%H%M%S).log"
docker logs "$CONTAINER" > "$LOG_FILE" 2>&1 || true
echo "Logs sauvegardés dans ${LOG_FILE}"

# Arrêt du conteneur API uniquement (db et volumes intacts)
docker stop "$CONTAINER" 2>/dev/null || true
docker rm "$CONTAINER" 2>/dev/null || true

# Retag vers le nom d'image attendu par docker compose, pour que
# "docker compose up" réutilise cette version stable sans rebuild.
COMPOSE_IMAGE=$(docker compose config --images | grep -i "api$" | head -n 1)
if [ -z "$COMPOSE_IMAGE" ]; then
  echo "ERREUR : impossible de déterminer le nom d'image attendu par docker compose."
  exit 1
fi
docker tag "$TARGET_IMAGE" "$COMPOSE_IMAGE"
echo "Image ${TARGET_IMAGE} taguée comme ${COMPOSE_IMAGE}"

docker compose up -d --no-deps api

echo "Attente que l'API soit prête..."
sleep 5

echo "Nouvelle version déployée :"
docker inspect "$CONTAINER" --format='  {{.Config.Image}}'

echo "=== Rollback terminé. Lance scripts/smoke-test.sh pour vérifier. ==="