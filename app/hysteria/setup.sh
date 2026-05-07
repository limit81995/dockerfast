if [ -f ./.env ]; then
  set -a
  . ./.env
  set +a
fi
# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
# APP通用安装目录地址
CONTAINERS_APP_DIR=${SETUP_CURRENT_DIR}/../../containers/${APP_NAME}

mkdir -p ${CONTAINERS_APP_DIR}
#暴露的环境变量
export APP_NAME=${APP_NAME}
export CONTAINERS_APP_DIR=${CONTAINERS_APP_DIR}

NODE_IP=$(curl -4s https://api.ipify.org)

cat > ${CONTAINERS_APP_DIR}/config.yaml <<EOF
listen: :${APP_PORT}
trafficStats:
  listen: :${API_PORT}

tls:
  cert: /etc/server.crt
  key: /etc/server.key
auth:
  type: ${AUTH_TYPE}
  password: ${AUTH_PASSWORD}
  http:
    url: ${AUTH_HTTP_URL}?ip=${NODE_IP}
ignoreClientBandwidth: false
masquerade:
  type: proxy
  proxy:
    url: https://www.bing.com
    rewriteHost: true
EOF

cat ./server.crt > ${CONTAINERS_APP_DIR}/server.crt
cat ./server.key > ${CONTAINERS_APP_DIR}/server.key

docker-compose up -d
