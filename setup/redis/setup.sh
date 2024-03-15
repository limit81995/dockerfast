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
CONTAINS_APP_DIR=${SETUP_CURRENT_DIR}/../../contains/${APP_NAME}

# 运行SETUP初始化脚本
sh ${SETUP_CURRENT_DIR}/../init.sh

# 如果contains中没有配置文件，则复制默认配置文件

if !(test -f "${CONTAINS_APP_DIR}/conf/redis.conf"); then
  cp ${SETUP_CURRENT_DIR}/redis.conf ${CONTAINS_APP_DIR}/conf/redis.conf
fi

############ 安装脚本

docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} .

docker run \
--name ${APP_CONTAINER_NAME} \
-v ${CONTAINS_APP_DIR}/data:/data \
-v ${CONTAINS_APP_DIR}/conf:/usr/local/etc \
-p ${APP_PORT}:6379 \
-d ${IMAGE_NAME}:${IMAGE_VERSION} \
redis-server /usr/local/etc/redis.conf


################################################