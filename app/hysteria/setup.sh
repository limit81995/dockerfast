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

NODE_IP=$(curl -4s https://api.ipify.org)
if [ -z "${NODE_IP}" ]; then
    echo "Error: NODE_IP is empty." >&2
    exit 1
fi

#暴露的环境变量
export APP_NAME=${APP_NAME}
export CONTAINERS_APP_DIR=${CONTAINERS_APP_DIR}
export NODE_IP=${NODE_IP}

# 根据模板生成配置文件
envsubst < temp.yaml > ${CONTAINERS_APP_DIR}/config.yaml

cat ./server.crt > ${CONTAINERS_APP_DIR}/server.crt
cat ./server.key > ${CONTAINERS_APP_DIR}/server.key

docker-compose up -d
