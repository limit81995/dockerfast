#!/usr/bin/env bash
set -e

# 允许用 sh setup.sh 调用。
if [ -z "${BASH_VERSION}" ]; then
  exec bash "$0" "$@"
fi

source "$(dirname "${BASH_SOURCE[0]}")/../common/init.sh"
app_init "${BASH_SOURCE[0]}" --allow-missing-env

#----------------------------------------------
# .env 仅提供本次交互的默认值，不自动保存输入。
prompt_config() {
  local name=$1 label=$2 rule=${3:-optional} secret=${4:-false}
  local default_value='' value hint
  if [[ -f "${SETUP_CURRENT_DIR}/.env" ]]; then
    default_value=${!name}
  fi

  while true; do
    if [[ -z "$default_value" ]]; then
      hint="无默认值"
    elif [[ "$secret" == true ]]; then
      hint="已配置，回车保留"
    else
      hint="默认：${default_value}"
    fi
    printf '%s (%s) [%s]: ' "$label" "$name" "$hint" >&2
    if [[ "$secret" == true ]]; then
      if ! IFS= read -r -s value; then
        printf '\n未读取到输入，已取消创建 runner。\n' >&2
        exit 1
      fi
      printf '\n' >&2
    elif ! IFS= read -r value; then
      printf '\n未读取到输入，已取消创建 runner。\n' >&2
      exit 1
    fi

    value=${value:-$default_value}
    [[ "$value" != - ]] || value=
    case "$rule" in
      required)
        [[ -n "$value" ]] || { echo "此项必填，请重新输入。" >&2; continue; }
        ;;
      count)
        [[ "$value" =~ ^[1-9][0-9]*$ ]] || { echo "请输入大于 0 的整数。" >&2; continue; }
        ;;
      prefix)
        [[ "$value" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]] || { echo "名称前缀须以字母或数字开头，仅包含字母、数字、下划线、点或短横线。" >&2; continue; }
        ;;
    esac
    printf -v "$name" '%s' "$value"
    export "${name?}"
    break
  done
}

echo "请逐项输入配置；回车使用 .env 默认值，输入 - 清空可选项。"
prompt_config RUNNER_COUNT "创建数量" count
prompt_config RUNNER_NAME_PREFIX "名称前缀" prefix
while true; do
  prompt_config RUNNER_TOKEN "Runner 注册令牌（与 ACCESS_TOKEN 至少填一项）" optional true
  prompt_config ACCESS_TOKEN "个人访问令牌" optional true
  [[ -n "${RUNNER_TOKEN}${ACCESS_TOKEN}" ]] && break
  echo "RUNNER_TOKEN 和 ACCESS_TOKEN 至少填写一项，请重新输入。" >&2
done
prompt_config RUNNER_SCOPE "Runner 作用域（如 org 或 repo）" required
org_rule=optional
repo_rule=optional
[[ "$RUNNER_SCOPE" != org ]] || org_rule=required
[[ "$RUNNER_SCOPE" != repo ]] || repo_rule=required
prompt_config ORG_NAME "组织名称（org 作用域必填）" "$org_rule"
prompt_config REPO_URL "仓库地址（repo 作用域必填）" "$repo_rule"
prompt_config RUNNER_GROUP "Runner 分组"
prompt_config LABELS "Runner 标签（逗号分隔）"
prompt_config START_DOCKER_SERVICE "启动容器内 Docker（仅 true 启用）"
prompt_config RUNNER_IMAGE "Runner 镜像" required

# 仅启动容器内 Docker 时检查并使用 Sysbox runtime。
runtime_args=()
if [[ "${START_DOCKER_SERVICE:-}" == "true" ]]; then
  runtimes=$(docker info --format '{{json .Runtimes}}')
  [[ "$runtimes" == *'"sysbox-runc":'* ]] || { echo "未检测到 Sysbox，请先在 Docker 宿主机安装并注册 sysbox-runc。" >&2; exit 1; }
  runtime_args=(--runtime=sysbox-runc)
fi

# 4 位随机后缀，避免重名。
rand_hash() {
  od -An -N2 -tx1 /dev/urandom | tr -d ' \n'
}

i=0
while [ "${i}" -lt "${RUNNER_COUNT}" ]; do
  i=$((i + 1))

  CONTAINER_NAME="${RUNNER_NAME_PREFIX}-$(rand_hash)"

  docker run -d --restart always --name "${CONTAINER_NAME}" \
    "${runtime_args[@]}" \
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
