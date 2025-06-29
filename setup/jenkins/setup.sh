################################################

################## 容器配置

# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
# 镜像名称
IMAGE_NAME="jenkins/jenkins"
#APP 镜像版本号
IMAGE_VERSION="lts-jdk17"

# 端口
APP_PORT="8080"
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

if [ ! -d ${CONTAINERS_APP_DIR}/logs ]; then
  mkdir ${CONTAINERS_APP_DIR}/logs
fi

############ 安装脚本
docker run -d -v /home/${USER}/.ssh:/var/jenkins_home/.ssh:ro -v ${CONTAINERS_APP_DIR}/data:/var/jenkins_home -p ${APP_PORT}:8080 -p 50000:50000 --restart=on-failure -e JAVA_OPTS=-Duser.timezone=Asia/Shanghai ${IMAGE_NAME}:${IMAGE_VERSION}
################################################