#!/usr/bin/env bash
set -e

# 允许用 sh setup.sh 调用。
if [ -z "${BASH_VERSION}" ]; then
  exec bash "$0" "$@"
fi

source "$(dirname "${BASH_SOURCE[0]}")/../common/init.sh"
app_init "${BASH_SOURCE[0]}"

#----------------------------------------------
[ -n "${RUNNER_TOKEN:-}${ACCESS_TOKEN:-}" ] || { echo "请在 .env 中配置 RUNNER_TOKEN 或 ACCESS_TOKEN" >&2; exit 1; }

# 检查 Docker 是否已注册 Sysbox runtime。
runtimes=$(docker info --format '{{json .Runtimes}}')
[[ "$runtimes" == *'"sysbox-runc":'* ]] || { echo "未检测到 Sysbox，请先在 Docker 宿主机安装并注册 sysbox-runc。" >&2; exit 1; }

# 4 位随机后缀，避免重名。
rand_hash() {
  od -An -N2 -tx1 /dev/urandom | tr -d ' \n'
}

i=0
while [ "${i}" -lt "${RUNNER_COUNT}" ]; do
  i=$((i + 1))

  CONTAINER_NAME="${RUNNER_NAME_PREFIX}-$(rand_hash)"

  docker run -d --restart always --name "${CONTAINER_NAME}" \
    --runtime=sysbox-runc \
    --tmpfs /run:mode=755 \
    ${START_DOCKER_SERVICE:+-e START_DOCKER_SERVICE} \
    ${RUNNER_TOKEN:+-e RUNNER_TOKEN} \
    ${ACCESS_TOKEN:+-e ACCESS_TOKEN} \
    -e RUNNER_NAME="${CONTAINER_NAME}" \
    -e RUNNER_WORKDIR="/data/runner/${CONTAINER_NAME}" \
    ${RUNNER_GROUP:+-e RUNNER_GROUP} \
    ${RUNNER_SCOPE:+-e RUNNER_SCOPE} \
    ${ORG_NAME:+-e ORG_NAME} \
    ${REPO_URL:+-e REPO_URL} \
    -e DISABLE_AUTO_UPDATE="true" \
    -e LABELS="${LABELS}" \
    -v "${CONTAINERS_APP_DIR}/${CONTAINER_NAME}:/data/runner/${CONTAINER_NAME}" \
    "${RUNNER_IMAGE}"

  echo "已创建 ${CONTAINER_NAME}"
done
