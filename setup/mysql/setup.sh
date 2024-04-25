################################################

################## 容器配置

# 当前脚本路径
SETUP_CURRENT_DIR=$(cd $(dirname $0);pwd)
#APP 名称
APP_NAME=${SETUP_CURRENT_DIR##*/};
APP_ROOT_PASSWORD=123456
# 镜像名称
IMAGE_NAME="mysql"
# 镜像版本号
IMAGE_VERSION="8.0.30"
# 端口
APP_PORT="3306"
# 容器名称
APP_CONTAINER_NAME="${APP_NAME}"
# APP通用安装目录地址
CONTAINS_APP_DIR=${SETUP_CURRENT_DIR}/../../contains/${APP_NAME}

# 运行SETUP初始化脚本
sh ${SETUP_CURRENT_DIR}/../init.sh

# 如果contains中没有配置文件，则复制默认配置文件

 if !(test -f "${CONTAINS_APP_DIR}/conf/my.cnf"); then
   cp ${SETUP_CURRENT_DIR}/my.cnf ${CONTAINS_APP_DIR}/conf/my.cnf
 fi

############ 安装脚本



docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} .

docker run \
--name ${APP_CONTAINER_NAME} \
-v ${CONTAINS_APP_DIR}/data:/var/lib/mysql \
-v ${CONTAINS_APP_DIR}/conf:/etc/mysql/conf.d \
-e MYSQL_ROOT_PASSWORD=123456 \
-p ${APP_PORT}:3306 \
-d ${IMAGE_NAME}:${IMAGE_VERSION}



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