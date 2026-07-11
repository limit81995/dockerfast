## 加载.env 配置文件到脚本中
if [ -f ./.env ]; then
  set -a
  . ./.env
  set +a
fi

# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
# APP通用安装目录地址
CONTAINERS_APP_DIR=${SETUP_CURRENT_DIR}/../../containers/${APP_NAME}

mkdir -p ${CONTAINERS_APP_DIR}

#暴露的环境变量
export APP_NAME=${APP_NAME}
export CONTAINERS_APP_DIR=${CONTAINERS_APP_DIR}

########  以上为通用配置无需调整  ########



########  以下是自定义内容  ########

cat ./postgresql.conf > ${CONTAINERS_APP_DIR}/postgresql.conf

# 创建共用网络
docker network create --driver bridge local_network || true
docker compose down && docker compose up -d

# 容器地址：数据库配置地址 /etc/postgresql/postgresql.conf 数据库地址：/var/lib/postgresql/data
