# 当前脚本目录
SETUP_ROOT_DIR=$(cd $(dirname $0);pwd);
# 创建contains目录
PUBLIC_CONTAINS_DIR=${SETUP_ROOT_DIR}/../contains;
mkdir ${PUBLIC_CONTAINS_DIR};
# 遍历获取setup APP目录，并创建APP对应的contains
for file in $(ls -d ${SETUP_ROOT_DIR}/*/);do
 file=${file%*/};
#  APP目录名称
 APP_NAME=${file##*/};

# 目录名称判断
# if [ ${APP_NAME} == "contains" ] ;then
#  continue;
# fi

 mkdir ${PUBLIC_CONTAINS_DIR}/${APP_NAME};
 mkdir ${PUBLIC_CONTAINS_DIR}/${APP_NAME}/data;
 mkdir ${PUBLIC_CONTAINS_DIR}/${APP_NAME}/conf;
 done