# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
# APP通用安装目录地址
CONTAINERS_APP_DIR=${SETUP_CURRENT_DIR}/../../containers/${APP_NAME}

mkdir -p ${CONTAINERS_APP_DIR}/conf
cat ./my.cnf > ${CONTAINERS_APP_DIR}/conf/my.cnf

#暴露的环境变量
export APP_NAME=${APP_NAME}
export CONTAINERS_APP_DIR=${CONTAINERS_APP_DIR}

# 初始化时默认全网可连
echo "UPDATE mysql.user AS u  LEFT JOIN mysql.user AS r  ON r.user = 'root' AND r.host = '%' SET u.host = '%' WHERE u.user = 'root' AND u.host = 'localhost' AND r.user IS NULL; FLUSH PRIVILEGES;" > ${CONTAINERS_APP_DIR}/init.sql

# 创建共用网络
docker network create --driver bridge local_network || true
docker-compose up -d

# 容器地址：   数据库配置地址 /etc/mysql/conf.d/mysql.cnf 数据库地址：/var/lib/mysql