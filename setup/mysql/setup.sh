source ../config.sh
docker build .
echo "正在安装MYSQL...(INSTALLING MYSQL...)"
docker run --name ${MYSQL_CONTAINER_NAME} -v ${MYSQL_DATA_DIR}:/var/lib/mysql -p ${MYSQL_PORT}:3306 -e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} -d  mysql:latest
# 容器地址：   数据库配置地址 /etc/mysql/conf.d/mysql.cnf 数据库地址：/var/lib/mysql