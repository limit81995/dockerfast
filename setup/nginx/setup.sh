################################################

################## 容器配置

# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
# 镜像名称
IMAGE_NAME="nginx"
# 镜像版本号
IMAGE_VERSION="1.25"
# 端口
APP_PORT="80"
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

# 如果contains中没有配置文件，则复制默认配置文件

if !(test -f "${CONTAINERS_APP_DIR}/conf/nginx.conf"); then
  cp ${SETUP_CURRENT_DIR}/temp/nginx.conf ${CONTAINERS_APP_DIR}/conf/nginx.conf
fi

if [ ! -d ${CONTAINERS_APP_DIR}/conf/conf.d ]; then
  mkdir ${CONTAINERS_APP_DIR}/conf/conf.d
fi

############ 安装脚本

docker run \
--name ${APP_CONTAINER_NAME} \
-v ${CONTAINERS_APP_DIR}/data:/usr/share/nginx/html \
-v ${CONTAINERS_APP_DIR}/conf/nginx.conf:/etc/nginx/nginx.conf \
-v ${CONTAINERS_APP_DIR}/conf/conf.d:/etc/nginx/conf.d \
-p ${APP_PORT}:80 \
-d ${IMAGE_NAME}:${IMAGE_VERSION}

###############################################