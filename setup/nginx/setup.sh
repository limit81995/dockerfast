################## REDIS配置 ###################

#容器名称
APP_CONTAINER_NAME="nginx_latest"
#对外端口
APP_PORT=80

###############################################



################## 安装常量配置 ###################

# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd) 
# 通用目录地址
CONTAINS_DIR=${SETUP_CURRENT_DIR}"/../../contains"
# APP通用安装目录地址
CONTAINS_APP_DIR=${CONTAINS_DIR}"/nginx"
# 本地数据映射目录
APP_DATA_DIR=${CONTAINS_APP_DIR}"/data"
# 本地配置映射目录
APP_CONF_DIR=${CONTAINS_APP_DIR}"/conf"

###############################################



################## 安装脚本 ###################

docker build ${SETUP_CURRENT_DIR}/.
echo "\033[31m INSTALLING NGINX ... \033[0m"
echo 

# 创建需要的文件夹目录

mkdir ${CONTAINS_DIR}
mkdir ${CONTAINS_APP_DIR}
mkdir ${APP_CONF_DIR}
mkdir ${APP_DATA_DIR}

docker run \
--name ${APP_CONTAINER_NAME} \
-v ${APP_DATA_DIR}:/usr/share/nginx/html \
-p ${APP_PORT}:80 \
-d  nginx:latest

###############################################