################## REDIS配置 ###################

#容器名称
APP_CONTAINER_NAME="mysql_latest"
#ROOT密码
APP_ROOT_PASSWORD="123456"
#对外端口
APP_PORT=3306

###############################################



################## 安装常量配置 ###################

# 镜像名称
IMAGES_NAME="mysql"
# 镜像版本
IMAGES_VERSION="latest"
# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd) 
# 通用目录地址
CONTAINS_DIR=${SETUP_CURRENT_DIR}"/../../contains"
# APP通用安装目录地址
CONTAINS_APP_DIR=${CONTAINS_DIR}"/mysql"
# 本地数据映射目录
APP_DATA_DIR=${CONTAINS_APP_DIR}"/data"
# 本地配置映射目录
APP_CONF_DIR=${CONTAINS_APP_DIR}"/conf"

###############################################



################## 安装脚本 ###################

docker build -t ${IMAGES_NAME}:${IMAGES_VERSION} ${SETUP_CURRENT_DIR}/.
echo "\033[31m INSTALLING MYSQL ... \033[0m"

# 创建需要的文件夹目录

mkdir ${CONTAINS_DIR}
mkdir ${CONTAINS_APP_DIR}
mkdir ${CONTAINS_APP_DIR}/conf
mkdir ${CONTAINS_APP_DIR}/data

docker run \
--name ${APP_CONTAINER_NAME} \
-v ${APP_DATA_DIR}:/var/lib/mysql \
-p ${APP_PORT}:3306 \
-e MYSQL_ROOT_PASSWORD=${APP_ROOT_PASSWORD} \
-d  mysql:latest

# 容器地址：   数据库配置地址 /etc/mysql/conf.d/mysql.cnf 数据库地址：/var/lib/mysql

###############################################