#!/usr/bin/env bash

# 初始化应用通用变量和目录。
# 参数必须是调用方 setup.sh 的路径，例如：app_init "${BASH_SOURCE[0]}"
app_init() {
  echo "初始化脚本.."
  local setup_file=${1:?app_init 需要传入 setup.sh 的路径}
  local app_dir

  app_dir=$(cd "$(dirname "${setup_file}")"; pwd)

  # 始终根据 setup.sh 的位置加载对应应用的 .env，不依赖当前工作目录。
  if [[ -f "${app_dir}/.env" ]]; then
    set -a
    source "${app_dir}/.env"
    set +a
  fi

  # 这些路径变量由应用位置决定，不允许被 .env 覆盖。
  export SETUP_CURRENT_DIR=${app_dir}
  export APP_NAME=${SETUP_CURRENT_DIR##*/}
  export CONTAINERS_APP_DIR=${SETUP_CURRENT_DIR}/../../containers/${APP_NAME}

  mkdir -p "${CONTAINERS_APP_DIR}"

if [[ ! -f "${SETUP_CURRENT_DIR}/.env" ]]; then
  echo "缺少 app/open-webui/.env，请先复制 .env.example 并修改配置。" >&2
  exit 1
fi
}

# 创建本地共用网络
docker network create --driver bridge local_network || true
