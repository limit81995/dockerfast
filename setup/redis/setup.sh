################## REDIS配置 ###################

# 容器名称
APP_CONTAINER_NAME="redis_latest"
# 端口
APP_PORT="6379"

###############################################



################## 安装常量配置 ###################

# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd) 
# 通用目录地址
CONTAINS_DIR=${SETUP_CURRENT_DIR}"/../../contains"
# APP通用安装目录地址
CONTAINS_APP_DIR=${CONTAINS_DIR}"/redis"
# 本地数据映射目录
APP_DATA_DIR=${CONTAINS_APP_DIR}"/data"
# 本地配置映射目录
APP_CONF_DIR=${CONTAINS_APP_DIR}"/conf"

###############################################



################## 安装脚本 ###################

docker build . 
echo "\033[31m INSTALLING REDIS ... \033[0m"

# 创建需要的文件夹目录
mkdir ${CONTAINS_DIR}
mkdir ${CONTAINS_APP_DIR}
mkdir ${CONTAINS_APP_DIR}/conf
mkdir ${CONTAINS_APP_DIR}/data
touch ${CONTAINS_APP_DIR}/data/.gitignore

echo "* \n # 除了一下文件 \n !.gitignore" > ${CONTAINS_APP_DIR}/data/.gitignore

# 复制配置文件
cp ${SETUP_CURRENT_DIR}/redis.conf ${APP_CONF_DIR}/redis.conf

docker run \
--name ${APP_CONTAINER_NAME} \
-v ${APP_DATA_DIR}:/data \
-v ${APP_CONF_DIR}:/usr/local/etc \
-p ${APP_PORT}:6379 \
-d redis:latest \
redis-server /usr/local/etc/redis.conf

### 数据地址：/data

################################################