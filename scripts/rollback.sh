#!/bin/sh
set -eu

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "Usage: $0 <version>"
  echo "Exemple: $0 v1.0.0"
  echo ""
  echo "Images disponibles :"
  docker images shoplite-api --format "  {{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
  exit 1
fi

IMAGE="shoplite-api:${TARGET}"

echo "======================================"
echo " ROLLBACK -> ${IMAGE}"
echo "======================================"

# 1. Exporter les logs avant rollback
LOG_FILE="/tmp/api-before-rollback-$(date +%Y%m%d-%H%M%S).log"
echo "[rollback] Sauvegarde logs -> ${LOG_FILE}"
docker compose logs api > "$LOG_FILE" 2>&1 || true

# 2. Vérifier que l'image cible existe
echo "[rollback] Vérification image ${IMAGE}"
if ! docker image inspect "$IMAGE" > /dev/null 2>&1; then
  echo "[rollback] ERREUR : image ${IMAGE} introuvable"
  echo "[rollback] Images disponibles :"
  docker images shoplite-api
  exit 1
fi
echo "[rollback] Image trouvée"

# 3. Redéployer avec la version cible (sans rebuild)
echo "[rollback] Redéploiement avec ${IMAGE} ..."
API_VERSION="$TARGET" docker compose up -d --no-build api

# 4. Attendre que l'API soit prête
echo "[rollback] Attente démarrage API..."
READY=0
i=0
while [ $i -lt 20 ]; do
  sleep 3
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/ready 2>/dev/null || echo "000")
  if [ "$CODE" = "200" ]; then
    READY=1
    break
  fi
  i=$((i+1))
  echo "[rollback]   tentative $i/20 (HTTP $CODE)"
done

if [ "$READY" -eq 0 ]; then
  echo "[rollback] ERREUR : API non disponible après rollback"
  exit 1
fi
echo "[rollback] API prête"

# 5. Smoke tests
echo "[rollback] Smoke tests..."
bash scripts/smoke-test.sh

echo ""
echo "======================================"
echo " Rollback vers ${TARGET} : OK"
echo " Données PostgreSQL : conservées"
echo "======================================"
