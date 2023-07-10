#### 安装脚本

# 当前脚本路径
CURRENT_DIR=$(cd $(dirname $0);pwd)

source ${CURRENT_DIR}/config.sh

docker build .
echo "INSTALLING REDIS ..."

docker run \
--name ${REDIS_CONTAINER_NAME} \
-v ${CURRENT_DIR}${REDIS_DATA_DIR}:/data \
-v ${CURRENT_DIR}${REDIS_CONF_DIR}:/usr/local/etc/redis \
-p ${REDIS_PORT}:6379 \
-d redis:latest 
# redis-server /usr/local/etc/redis/redis.conf

### 数据地址：/data