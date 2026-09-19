#!/usr/bin/env bash
set -e

if ! docker compose version >/dev/null 2>&1; then
  echo "Immich 需要 Docker Compose 插件，请先安装并确认 docker compose version 可用。" >&2
  exit 1
fi

# 引用公共初始化函数，并将当前 setup.sh 的位置传给它。
source "$(dirname "${BASH_SOURCE[0]}")/../common/init.sh"
app_init "${BASH_SOURCE[0]}"
#-------------------------------------------

mkdir -p "${CONTAINERS_APP_DIR}/data" "${CONTAINERS_APP_DIR}/model-cache"

DOCKER_COMPOSE_FILE=${SETUP_CURRENT_DIR}/docker-compose.yml
docker compose -f "${DOCKER_COMPOSE_FILE}" down && docker compose -f "${DOCKER_COMPOSE_FILE}" up -d
