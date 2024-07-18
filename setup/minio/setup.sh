################################################

################## 容器配置

# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
# 镜像名称
IMAGE_NAME="minio/minio"
#APP 镜像版本号
IMAGE_VERSION="latest"

# 端口
APP_PORT="9200"
CONSOLE_PORT="9201"
#管理员账号
MINIO_ROOT_USER=minioadmin
#管理员密码
MINIO_ROOT_PASSWORD=minioadmin
# 容器名称
APP_CONTAINER_NAME="${APP_NAME}"
# APP通用安装目录地址
CONTAINS_APP_DIR=${SETUP_CURRENT_DIR}/../../contains/${APP_NAME}

# 运行SETUP初始化脚本
sh ${SETUP_CURRENT_DIR}/../init.sh

# 如果contains中没有配置文件，则复制默认配置文件

# if !(test -f "${CONTAINS_APP_DIR}/conf/nginx.conf"); then
#   cp ${SETUP_CURRENT_DIR}/nginx.conf ${CONTAINS_APP_DIR}/conf/nginx.conf
# fi

############ 安装脚本
docker run -d\
   -p ${APP_PORT}:9000 \
   -p ${CONSOLE_PORT}:9001 \
   --name ${APP_NAME} \
   -v ${CONTAINS_APP_DIR}/data:/data \
   -e "MINIO_ROOT_USER=${MINIO_ROOT_USER}" \
   -e "MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}" \
   minio/minio server /data --console-address ":9001"

################################################