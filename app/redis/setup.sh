#!/usr/bin/env bash
set -e

# 引用公共初始化函数，并将当前 setup.sh 的位置传给它。
source "$(dirname "${BASH_SOURCE[0]}")/../common/init.sh"
app_init "${BASH_SOURCE[0]}"
#-------------------------------------------

if ! command -v envsubst >/dev/null 2>&1; then
  echo "缺少 envsubst，请先安装 gettext 或 gettext-base。" >&2
  exit 1
fi

# 每次启动前根据 .env 替换模板中的环境变量，生成配置。
mkdir -p "${CONTAINERS_APP_DIR}/conf"
envsubst < "${SETUP_CURRENT_DIR}/redis.conf" > "${CONTAINERS_APP_DIR}/conf/redis.conf"

DOCKER_COMPOSE_FILE=${SETUP_CURRENT_DIR}/docker-compose.yml
docker compose -f "${DOCKER_COMPOSE_FILE}" down && docker compose -f "${DOCKER_COMPOSE_FILE}" up -d
