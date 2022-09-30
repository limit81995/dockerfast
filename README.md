# dockerfast
docker容器快速生成脚本

# 声明
在使用docker的时候有时候需要换电脑，但是dockerfile有时候没有特别称心如意的，于是就自己写一个方便自己修改的。



## 使用说明
### SETUP 文件夹
setup文件夹里面都是第一次安装的内容，/setup/[APP名]。
```
cd dockerfast/setup/[app 包名]
```
里面有setup.sh文件，如果你有能力，可以自行修改。如果想直接用就  sh setup.sh  他会自行创建容器。并且将本来默认的容器映射目录装在 dockerfast/contains/[APP 名] 下。
