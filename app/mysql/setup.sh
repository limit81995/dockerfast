# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
# APP通用安装目录地址
CONTAINERS_APP_DIR=${SETUP_CURRENT_DIR}/../../containers/${APP_NAME}

# 检查容器目录是否存在 不存在则创建
if [ ! -d ${SETUP_CURRENT_DIR}/../../containers ]; then
  mkdir ${SETUP_CURRENT_DIR}/../../containers
fi

if [ ! -d ${CONTAINERS_APP_DIR} ]; then
  mkdir ${CONTAINERS_APP_DIR}
fi

if [ ! -d ${CONTAINERS_APP_DIR}/conf ]; then
  mkdir ${CONTAINERS_APP_DIR}/conf
  cat ./my.cnf > ${CONTAINERS_APP_DIR}/conf/my.cnf
fi

#暴露的环境变量
export APP_NAME=${APP_NAME}
export CONTAINERS_APP_DIR=${CONTAINERS_APP_DIR}

# 创建共用网络
docker network create --driver bridge local_network || true
docker-compose up -d

######### 注意：安装后需要将 mysql user表中的root用户的host 改为"%";用来所有地址都可以访问。
## 连接mysql
# mysql -uroot -p123456
## 修改root为可以所有远程访问的用户
# use mysql;
# update user set host="%" where user="root" and host="*";
## 修改root密码
# alter user 'root' identified by '123456';
## 刷新立即生效
# flush privileges;

# 容器地址：   数据库配置地址 /etc/mysql/conf.d/mysql.cnf 数据库地址：/var/lib/mysql

###############################################