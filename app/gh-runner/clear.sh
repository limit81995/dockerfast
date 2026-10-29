#!/usr/bin/env bash
set -e

if [ -z "${BASH_VERSION}" ]; then
  exec bash "$0" "$@"
fi

source "$(dirname "${BASH_SOURCE[0]}")/../common/init.sh"
app_init "${BASH_SOURCE[0]}"

: "${RUNNER_NAME_PREFIX:=docker-runner}"

# 删除本应用创建的所有 runner 容器。
for name in $(docker ps -a --filter "name=^${RUNNER_NAME_PREFIX}-" --format '{{.Names}}'); do
  docker rm -f "${name}" >/dev/null
  echo "已删除 ${name}"
done
