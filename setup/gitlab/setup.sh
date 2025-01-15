################################################

################## 容器配置

# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
# 镜像名称
IMAGE_NAME="gitlab/gitlab-ee"
#APP 镜像版本号
IMAGE_VERSION="16.10.2-ee.0"

EXTERNAL_URL="http://gitlab.gszzz.com"
# 端口
APP_PORT="9080"
HTTPS_APP_PORT="443"
SSH_PORT="9022"
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

# 如果containers中没有配置文件，则复制默认配置文件

# if !(test -f "${CONTAINERS_APP_DIR}/conf/nginx.conf"); then
#   cp ${SETUP_CURRENT_DIR}/nginx.conf ${CONTAINERS_APP_DIR}/conf/nginx.conf
# fi

############ 安装脚本

docker run -d \
--env GITLAB_OMNIBUS_CONFIG="external_url '${EXTERNAL_URL}:${APP_PORT}'; gitlab_rails['gitlab_shell_ssh_port'] = ${SSH_PORT}" \
-p ${APP_PORT}:${APP_PORT} \
-p ${HTTPS_APP_PORT}:${HTTPS_APP_PORT} \
-p ${SSH_PORT}:${SSH_PORT} \
--name ${APP_CONTAINER_NAME} \
--restart always \
-v ${CONTAINERS_APP_DIR}/conf:/etc/gitlab \
-v ${CONTAINERS_APP_DIR}/logs:/var/log/gitlab \
-v ${CONTAINERS_APP_DIR}/data:/var/opt/gitlab \
--shm-size 256m \
${IMAGE_NAME}:${IMAGE_VERSION}

################################################