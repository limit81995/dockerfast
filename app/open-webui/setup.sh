#!/usr/bin/env bash

# 引用公共初始化函数，并将当前 setup.sh 的位置传给它。
source "$(dirname "${BASH_SOURCE[0]}")/../common/init.sh"
app_init "${BASH_SOURCE[0]}"
#-------------------------------------------

DOCKER_COMPOSE_FILE=${SETUP_CURRENT_DIR}/docker-compose.yml
docker compose -f ${DOCKER_COMPOSE_FILE} down && docker compose -f ${DOCKER_COMPOSE_FILE} up -d