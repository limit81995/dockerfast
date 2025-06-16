################################################

#注意构建容器前，请先创建数据库和初始化根目录的SQL文件

################## 容器配置

# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
# 镜像名称
IMAGE_NAME="nacos/nacos-server"
#APP 镜像版本号
IMAGE_VERSION="latest"
#数据库配置
MYSQL_HOST="192.168.66.201"
MYSQL_PORT="3306"
MYSQL_DB_NAME="nacos"
MYSQL_USER="nacos"
MYSQL_PASSWORD="nacosadmin"


# 对外端口
APP_PORT="8848"
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
docker run -d --name ${APP_CONTAINER_NAME} \
  -p ${APP_PORT}:8848 \
  -e MODE=standalone \
  -e SPRING_DATASOURCE_PLATFORM=mysql \
  -e MYSQL_SERVICE_HOST=${MYSQL_HOST} \
  -e MYSQL_SERVICE_PORT=${MYSQL_PORT} \
  -e MYSQL_SERVICE_DB_NAME=${MYSQL_DB_NAME} \
  -e MYSQL_SERVICE_USER=${MYSQL_USER} \
  -e MYSQL_SERVICE_PASSWORD=${MYSQL_PASSWORD} \
  -e MYSQL_SERVICE_DB_PARAM="characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useUnicode=true&useSSL=false&serverTimezone=Asia/Shanghai&allowPublicKeyRetrieval=true" \
  -e NACOS_AUTH_IDENTITY_KEY=2222 \
  -e NACOS_AUTH_IDENTITY_VALUE=2xxx \
  -e NACOS_AUTH_TOKEN=SecretKey012345678901234567890123456789012345678901234567890123456789 \
  ${IMAGE_NAME}:${IMAGE_VERSION}
################################################