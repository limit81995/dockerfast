# dockerfast
docker容器快速生成脚本

# 声明
在使用docker的时候有时候需要换电脑，但是dockerfile有时候没有特别称心如意的，于是就自己写一个方便自己修改的。

## 注意：
如果提示source：not found!
### ubuntu解决：
请按以下步骤更改Shell的解释器：
执行ls -l /bin/sh命令，若得到结果/bin/sh -> dash，则说明Shell的解释器为dash。
执行dpkg-reconfigure dash命令，然后选择no。
重要 此步骤需要root权限。
再次执行ls -l /bin/sh命令，若得到结果/bin/sh -> bash，则说明成功更改Shell的解释器为bash。


## 使用说明
### SETUP 文件夹
setup文件夹里面都是第一次安装的内容，/setup/[APP名]。
```
cd dockerfast/setup/[app 包名]
```
里面有setup.sh文件，如果你有能力，可以自行修改。如果想直接用就  sh setup.sh  他会自行创建容器。并且将本来默认的容器映射目录装在 dockerfast/contains/[APP 名] 下。