docker build .

#容器名称
CONTAINER_NAME="mysql_latest"
#数据库ROOT密码
PSD="123456" 
#本地数据映射地址
LOCAL_DATA_DIR=$(pwd)"/../../contains/mysql/data"
echo ${LOCAL_DATA_DIR}
docker run --name ${CONTAINER_NAME} -v ${LOCAL_DATA_DIR}:/var/lib/mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=${PSD} -d  mysql:latest
# 容器地址：   数据库配置地址 /etc/mysql/conf.d/mysql.cnf 数据库地址：/var/lib/mysql
