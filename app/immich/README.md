# Immich

沿用公共 `app_init`，部署 Immich 服务和机器学习服务，连接已有 PostgreSQL、Redis。默认固定为 `v3.2.2`，两个服务使用同一版本。

## 配置与启动

```bash
cd app/immich
cp .env.example .env
```

编辑 `.env`，填写已有 PG、Redis 的连接参数，再运行：

```bash
bash setup.sh
```

访问 `http://服务器地址:2283`，端口由 `APP_PORT` 控制。照片和视频保存在 `containers/immich/data`，模型缓存保存在 `containers/immich/model-cache`。

## 外部服务

- 默认用 `postgresql`、`redis` 容器名连接仓库中的服务，要求它们已启动并加入 `local_network`。容器之间使用内部端口 `5432`、`6379`；远程服务则填写实际地址与端口。`localhost` 指 Immich 容器自身。
- PG 需提前创建独立的 `immich` 数据库，连接用户需要具备建表和迁移权限。默认 `DB_VECTOR_EXTENSION=pgvector`，对应仓库的 `pgvector/pgvector:pg16` 镜像；数据库需启用 `vector` 和 `earthdistance` 扩展（后者依赖 `cube`）。使用非超级用户时，请由管理员提前安装扩展并授予数据库所有权。使用 VectorChord 时按官方外部 PG 指南配置，并修改 `DB_VECTOR_EXTENSION`。
- Redis 密码与已有 Redis 保持一致，无密码可留空。`REDIS_DBINDEX` 默认 `1`，应调整为未被其他应用使用的数据库索引。
- setup 启动的 Immich 会在指定数据库执行自身迁移；PG、Redis 由各自的部署配置管理。

需要可用的 `docker compose` 插件。脚本会预先检查，不支持旧版 `docker-compose`。环境变量直接由 Compose 读取，无需 `envsubst`。修改 `.env` 后重新运行 setup 会重建 Immich 容器并保留挂载数据。

## 官方文档

- [Docker Compose 安装](https://docs.immich.app/install/docker-compose/)
- [环境变量](https://docs.immich.app/install/environment-variables/)
- [使用已有 PostgreSQL](https://docs.immich.app/administration/postgres-standalone/)
- [运行要求](https://docs.immich.app/install/requirements/)
