#!/usr/bin/env bash
set -e

if [ -z "${BASH_VERSION}" ]; then
  exec bash "$0" "$@"
fi
set -o pipefail

command -v docker >/dev/null || { echo "缺少 docker，请先安装并配置 Docker" >&2; exit 1; }

source "$(dirname "${BASH_SOURCE[0]}")/../common/init.sh"
app_init "${BASH_SOURCE[0]}"

: "${RUNNER_NAME_PREFIX:=docker-runner}"
echo "查找需要清理的 runner 容器..."
if ! containers=$(docker ps -a --filter "name=^${RUNNER_NAME_PREFIX}-" --format '{{.Names}}'); then
  echo "查询 runner 容器失败，请检查 Docker 服务及访问权限" >&2
  exit 1
fi
[ -n "${containers}" ] || { echo "没有需要清理的 runner 容器"; exit 0; }

: "${ACCESS_TOKEN:?请在 .env 中配置 ACCESS_TOKEN，用于注销 runner}"
: "${ORG_NAME:?请在 .env 中配置 ORG_NAME}"
[ "${RUNNER_SCOPE:-org}" = org ] || { echo "clear.sh 当前仅支持组织级 runner" >&2; exit 1; }
command -v curl >/dev/null || { echo "缺少 curl，请先安装 curl" >&2; exit 1; }
command -v jq >/dev/null || { echo "缺少 jq，请先安装 jq" >&2; exit 1; }
api_url="https://api.github.com/orgs/${ORG_NAME}/actions/runners"

# 统一调用 GitHub API；令牌从标准输入传入，避免出现在命令行参数中。
github_api() {
  curl --fail --silent --show-error --connect-timeout 10 --max-time 30 \
    --header @- --header 'Accept: application/vnd.github+json' \
    "$@" <<< "Authorization: Bearer ${ACCESS_TOKEN}"
}

# 停止前、停止后复用同一查询与校验，避免误删或使用已自动注销的旧记录。
get_runner_id() {
  local name=$1 runners
  if ! runners=$(github_api --get --data-urlencode "name=${name}" --data 'per_page=100' "${api_url}"); then
    echo "${name} 查询 GitHub runner 失败，请检查网络、组织和 ACCESS_TOKEN 权限" >&2
    return 1
  fi
  if ! jq -er --arg name "${name}" '
    if (.runners | type) != "array" or (.total_count | type) != "number" or .total_count != (.runners | length)
      then error("runner 查询结果异常，保留容器")
    else [.runners[] | select(.name == $name)] |
      if length > 1 then error("存在多个同名 runner，保留容器")
      elif length == 0 then ""
      elif (.[0].id | type) != "number" then error("runner ID 无效，保留容器")
      else .[0].id end
    end' <<< "${runners}"; then
    echo "${name} 的 GitHub 查询结果校验失败" >&2
    return 1
  fi
}

for name in ${containers}; do
  # 1. 确认组织与完整 runner 名，并在停止前检查 GitHub 查询是否正常。
  echo "[${name}] 检查容器归属..."
  docker inspect --format '{{json .Config.Env}}' "${name}" |
    jq -e --arg org "ORG_NAME=${ORG_NAME}" --arg name "RUNNER_NAME=${name}" \
      'index($org) != null and index($name) != null and index("RUNNER_SCOPE=org") != null' >/dev/null || {
        echo "${name} 的容器检查失败，或组织、runner 名不匹配，停止清理" >&2
        exit 1
      }

  echo "[${name}] 检查 GitHub 查询访问及注册记录..."
  # 查询成功只能确认读取权限，注销所需的写权限仍由 DELETE 请求验证。
  if ! runner_id=$(get_runner_id "${name}"); then
    echo "${name} 停止前检查失败，未停止或删除当前容器" >&2
    exit 1
  fi

  # 2. 先停止容器并关闭自动重启，避免注销后又重新注册。
  echo "[${name}] 关闭自动重启并停止容器..."
  if ! docker update --restart=no "${name}" >/dev/null; then
    echo "${name} 关闭自动重启失败，停止清理" >&2
    exit 1
  fi
  if ! docker stop --time 30 "${name}" >/dev/null; then
    echo "${name} 停止失败，保留容器；自动重启已关闭" >&2
    exit 1
  fi

  # 3. 正常停止可能已自动注销，必须重新查询。
  echo "[${name}] 确认停止后的 GitHub 注册记录..."
  if ! runner_id=$(get_runner_id "${name}"); then
    echo "${name} 停止后查询失败，保留已停止的容器；自动重启已关闭" >&2
    exit 1
  fi
  if [ -n "${runner_id}" ]; then
    echo "[${name}] 注销 GitHub runner..."
    if ! status=$(github_api --request DELETE --output /dev/null --write-out '%{http_code}' "${api_url}/${runner_id}"); then
      echo "${name} 注销请求失败（HTTP ${status:-未知}），保留已停止的容器；自动重启已关闭" >&2
      exit 1
    fi
    [ "${status}" = 204 ] || {
      echo "${name} 注销未成功（HTTP ${status}），保留已停止的容器；自动重启已关闭" >&2
      exit 1
    }
    echo "已注销 ${name}"
  else
    echo "${name} 已无远端注册记录"
  fi

  # 4. 注销成功或确认远端无记录后才删除容器；保留宿主挂载目录。
  echo "[${name}] 删除本地容器..."
  if ! docker rm "${name}" >/dev/null; then
    echo "${name} 本地容器删除失败，GitHub 注册记录已清理" >&2
    exit 1
  fi
  echo "已删除容器 ${name}"
done
