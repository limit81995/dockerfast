#!/usr/bin/env bash
set -e

# 允许用 sh setup.sh 调用。
if [ -z "${BASH_VERSION}" ]; then
  exec bash "$0" "$@"
fi

source "$(dirname "${BASH_SOURCE[0]}")/../common/init.sh"
app_init "${BASH_SOURCE[0]}"

#----------------------------------------------

# 4 位随机后缀，避免重名。
rand_hash() {
  od -An -N2 -tx1 /dev/urandom | tr -d ' \n'
}

i=0
while [ "${i}" -lt "${RUNNER_COUNT}" ]; do
  i=$((i + 1))

  CONTAINER_NAME="${RUNNER_NAME_PREFIX}-$(rand_hash)"

  docker run -d --restart always --name "${CONTAINER_NAME}" \
    -e RUNNER_NAME="${CONTAINER_NAME}" \
    -e RUNNER_TOKEN="${RUNNER_TOKEN}" \
    -e RUNNER_WORKDIR="/data/runner/${CONTAINER_NAME}" \
    -e RUNNER_GROUP=${RUNNER_GROUP} \
    -e RUNNER_SCOPE=${RUNNER_SCOPE} \
    -e DISABLE_AUTO_UPDATE="true" \
    -e ORG_NAME="${ORG_NAME}" \
    -e LABELS="${LABELS}" \
    -v "${CONTAINERS_APP_DIR}/${CONTAINER_NAME}:/data/runner/${CONTAINER_NAME}" \
    "${RUNNER_IMAGE}"

  echo "已创建 ${CONTAINER_NAME}"
done
