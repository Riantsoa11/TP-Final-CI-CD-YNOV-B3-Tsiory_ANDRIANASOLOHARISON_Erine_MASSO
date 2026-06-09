#!/bin/sh
set -eu

HOST="${SMOKE_HOST:-localhost}"
PORT="${SMOKE_PORT:-8080}"
BASE="http://${HOST}:${PORT}"
RETRIES=10
WAIT=3

echo "Smoke test -> ${BASE}"

wait_for() {
  url=$1
  i=0
  while [ $i -lt $RETRIES ]; do
    code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    if [ "$code" = "200" ]; then
      echo "  OK  $url"
      return 0
    fi
    i=$((i + 1))
    echo "  ... $url ($code) retry $i/$RETRIES"
    sleep $WAIT
  done
  echo "  FAIL $url after $RETRIES retries"
  return 1
}

FAIL=0

wait_for "${BASE}/api/health"   || FAIL=1
wait_for "${BASE}/api/products" || FAIL=1

if [ $FAIL -eq 0 ]; then
  echo "Smoke tests passed"
else
  echo "Smoke tests FAILED"
  exit 1
fi
