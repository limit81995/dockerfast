#!/usr/bin/env bash
set -e

if [ -z "${BASH_VERSION}" ]; then
  exec bash "$0" "$@"
fi
set -o pipefail

source "$(dirname "${BASH_SOURCE[0]}")/../common/init.sh"
app_init "${BASH_SOURCE[0]}"

: "${RUNNER_NAME_PREFIX:=docker-runner}"
containers=$(docker ps -a --filter "name=^${RUNNER_NAME_PREFIX}-" --format '{{.Names}}')
[ -n "${containers}" ] || { echo "没有需要清理的 runner 容器"; exit 0; }

: "${ACCESS_TOKEN:?请在 .env 中配置 ACCESS_TOKEN，用于注销 runner}"
: "${ORG_NAME:?请在 .env 中配置 ORG_NAME}"
[ "${RUNNER_SCOPE:-org}" = org ] || { echo "clear.sh 当前仅支持组织级 runner" >&2; exit 1; }
command -v curl >/dev/null
command -v jq >/dev/null
api_url="https://api.github.com/orgs/${ORG_NAME}/actions/runners"

# 统一调用 GitHub API；令牌从标准输入传入，避免出现在命令行参数中。
github_api() {
  curl --fail --silent --show-error --connect-timeout 10 --max-time 30 \
    --header @- --header 'Accept: application/vnd.github+json' \
    "$@" <<< "Authorization: Bearer ${ACCESS_TOKEN}"
}

for name in ${containers}; do
  # 1. 确认是当前组织的 runner，避免仅因容器名前缀相同而误删。
  docker inspect --format '{{json .Config.Env}}' "${name}" | \
    jq -e --arg org "ORG_NAME=${ORG_NAME}" --arg name "RUNNER_NAME=${name}" \
      'index($org) != null and index($name) != null and index("RUNNER_SCOPE=org") != null' >/dev/null || {
        echo "${name} 的组织或 runner 名不匹配，停止清理" >&2
        exit 1
      }

  # 2. 先停止容器并关闭自动重启，避免注销后又重新注册。
  docker update --restart=no "${name}" >/dev/null
  docker stop --time 30 "${name}" >/dev/null

  # 3. 正常停止可能已自动注销；再次查询，只删除完整名称对应的记录。
  runners=$(github_api --get --data-urlencode "name=${name}" --data 'per_page=100' "${api_url}")
  runner_id=$(jq -er --arg name "${name}" '
    if (.runners | type) != "array" or (.total_count | type) != "number" or .total_count != (.runners | length)
      then error("runner 查询结果异常，保留容器")
    else [.runners[] | select(.name == $name)] |
      if length > 1 then error("存在多个同名 runner，保留容器")
      elif length == 0 then ""
      elif (.[0].id | type) != "number" then error("runner ID 无效，保留容器")
      else .[0].id end
    end' <<< "${runners}")

  if [ -n "${runner_id}" ]; then
    status=$(github_api --request DELETE --output /dev/null --write-out '%{http_code}' "${api_url}/${runner_id}")
    [ "${status}" = 204 ] || { echo "${name} 注销失败，保留容器（HTTP ${status}）" >&2; exit 1; }
    echo "已注销 ${name}"
  else
    echo "${name} 已无远端注册记录"
  fi

  # 4. 注销成功后才删除容器；上面任一步失败都会停止，不执行这里。
  docker rm "${name}" >/dev/null
  echo "已删除容器 ${name}"
done
