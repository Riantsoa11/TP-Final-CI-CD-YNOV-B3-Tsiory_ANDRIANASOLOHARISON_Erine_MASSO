#!/bin/sh
set -eu

# ============================================================
# rollback.sh — Revenir à une version stable de l'API
# ============================================================
#
# Ce script prend en paramètre un TAG de version (ex: v1.0.0),
# et redéploie le conteneur "api" en utilisant l'image Docker
# correspondant à ce tag.
#
# RÈGLE D'OR DU TP : ce script ne doit JAMAIS supprimer les
# volumes (donc jamais "docker compose down -v"). La base
# PostgreSQL doit rester intacte avant et après le rollback.
#
# Usage :
#   ./scripts/rollback.sh v1.0.0
# ============================================================

# --- Vérification des arguments ---
# $# = nombre d'arguments passés au script.
# Si on n'a pas reçu exactement 1 argument, on affiche l'usage
# et on s'arrête (exit 1 = erreur).
if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>"
  echo "Exemple: $0 v1.0.0"
  exit 1
fi

VERSION="$1"
IMAGE_NAME="shoplite-api"
TARGET_IMAGE="${IMAGE_NAME}:${VERSION}"
CONTAINER="shoplite_api"

echo "=== Rollback vers ${TARGET_IMAGE} ==="

# --- Étape 1 : identifier la version actuellement déployée ---
# On utilise "docker inspect" pour lire l'image utilisée par
# le conteneur actuellement en cours d'exécution.
echo ""
echo "Version actuellement déployée :"
docker inspect "$CONTAINER" --format='  {{.Config.Image}}' 2>/dev/null || echo "  (conteneur non trouvé)"

# --- Étape 2 : vérifier que l'image cible existe en local ---
# "docker images -q" retourne l'ID de l'image si elle existe,
# ou rien (chaîne vide) si elle n'existe pas.
IMAGE_ID=$(docker images -q "$TARGET_IMAGE")

if [ -z "$IMAGE_ID" ]; then
  echo ""
  echo "ERREUR : l'image '${TARGET_IMAGE}' n'existe pas en local."
  echo "Images disponibles pour ${IMAGE_NAME} :"
  docker images "$IMAGE_NAME"
  exit 1
fi

echo ""
echo "Image cible trouvée : ${TARGET_IMAGE} (${IMAGE_ID})"

# --- Étape 3 : sauvegarder les logs actuels avant de toucher au conteneur ---
# Pratique pour le rapport d'incident : on garde une trace de
# l'état du conteneur juste avant le rollback.
mkdir -p ./logs
LOG_FILE="./logs/api_before_rollback_$(date -u +%Y%m%d_%H%M%S).log"
echo ""
echo "Sauvegarde des logs actuels dans ${LOG_FILE}..."
docker logs "$CONTAINER" > "$LOG_FILE" 2>&1 || true

# --- Étape 4 : redéployer le conteneur avec l'image ciblée ---
# IMPORTANT : on ne touche PAS aux volumes (la base PostgreSQL
# continue de tourner sans interruption pendant ce temps).
#
# "docker stop" + "docker rm" arrêtent et suppriment SEULEMENT
# le conteneur "api" — pas la base de données, pas les volumes.
echo ""
echo "Arrêt du conteneur actuel '${CONTAINER}'..."
docker stop "$CONTAINER" 2>/dev/null || true
docker rm "$CONTAINER" 2>/dev/null || true

# On retague l'image ciblée comme "latest" pour que
# "docker compose up" la réutilise automatiquement au prochain démarrage.
echo "Marquage de ${TARGET_IMAGE} comme image active..."
docker tag "$TARGET_IMAGE" "${IMAGE_NAME}:latest"

# On relance le service "api" avec docker compose.
# Compose va recréer le conteneur "api" en utilisant l'image
# qu'on vient de retaguer, et le reconnecter au réseau et à la
# base de données existants automatiquement.
echo "Redémarrage du service 'api' avec l'image ${VERSION}..."
docker compose up -d --no-deps api

# --- Étape 5 : vérification post-rollback ---
echo ""
echo "Attente que l'API soit prête..."
sleep 5

echo ""
echo "Nouvelle version déployée :"
docker inspect "$CONTAINER" --format='  {{.Config.Image}}'

echo ""
echo "=== Rollback terminé. Lance scripts/smoke-test.sh pour vérifier. ==="