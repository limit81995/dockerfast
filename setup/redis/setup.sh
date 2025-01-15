################################################

################## 容器配置

# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
# 镜像名称
IMAGE_NAME="redis"
#APP 镜像版本号
IMAGE_VERSION="latest"
# 端口
APP_PORT="6379"
# 容器名称
APP_CONTAINER_NAME="${APP_NAME}"
# APP通用安装目录地址
CONTAINERS_APP_DIR=${SETUP_CURRENT_DIR}/../../containers/${APP_NAME}

# 检查容器目录是否存在 不存在则创建
if [ ! -d ${SETUP_CURRENT_DIR}/../../containers ]; then
  mkdir ${SETUP_CURRENT_DIR}/../../containers
fi

if [ ! -d ${CONTAINERS_APP_DIR} ]; then
  mkdir ${CONTAINERS_APP_DIR}
fi

if [ ! -d ${CONTAINERS_APP_DIR}/data ]; then
  mkdir ${CONTAINERS_APP_DIR}/data
fi

if [ ! -d ${CONTAINERS_APP_DIR}/conf ]; then
  mkdir ${CONTAINERS_APP_DIR}/conf
fi

# 如果containers中没有配置文件，则复制默认配置文件

if !(test -f "${CONTAINERS_APP_DIR}/conf/redis.conf"); then
  cp ${SETUP_CURRENT_DIR}/temp/redis.conf ${CONTAINERS_APP_DIR}/conf/redis.conf
fi

############ 安装脚本

docker run \
--name ${APP_CONTAINER_NAME} \
-v ${CONTAINERS_APP_DIR}/data:/data \
-v ${CONTAINERS_APP_DIR}/conf:/usr/local/etc \
-p ${APP_PORT}:6379 \
-d ${IMAGE_NAME}:${IMAGE_VERSION} \
redis-server /usr/local/etc/redis.conf


################################################