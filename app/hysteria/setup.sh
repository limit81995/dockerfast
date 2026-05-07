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

if [ ! -f "${CONTAINERS_APP_DIR}/config.yaml" ]; then
    cat ./config.yaml > ${CONTAINERS_APP_DIR}/config.yaml
fi
cat ./server.crt > ${CONTAINERS_APP_DIR}/server.crt
cat ./server.key > ${CONTAINERS_APP_DIR}/server.key

docker-compose up -d
