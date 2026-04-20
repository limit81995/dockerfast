# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
# APP通用安装目录地址
CONTAINERS_APP_DIR=${SETUP_CURRENT_DIR}/../../containers/${APP_NAME}

mkdir -p ${SETUP_CURRENT_DIR}/../../containers
mkdir -p ${CONTAINERS_APP_DIR}/data
mkdir -p ${CONTAINERS_APP_DIR}/logs
  
docker run --rm -v "${CONTAINERS_APP_DIR}:/target" alpine chown -R 10001:10001 /target

#暴露的环境变量
export APP_NAME=${APP_NAME}
export CONTAINERS_APP_DIR=${CONTAINERS_APP_DIR}

# 创建共用网络
docker network create --driver bridge local_network || true
docker-compose up -d
