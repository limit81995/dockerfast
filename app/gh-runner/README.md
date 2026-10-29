# gh-runner

循环执行一条 `docker run` 批量创建 GitHub Actions Runner。

## 用法

```bash
cd app/gh-runner
cp .env.example .env      # 填 ACCESS_TOKEN
sh setup.sh               # 按 RUNNER_COUNT 创建
sh clear.sh               # 删除本应用的所有 runner 容器
```

## 命名

容器名 = runner 名 = `${RUNNER_NAME_PREFIX}-<4位随机>`，例如 `docker-runner-e597`。

```
RUNNER_NAME_PREFIX=docker-runner
RUNNER_WORKDIR     =/data/runner/docker-runner-e597
宿主挂载           =containers/gh-runner/docker-runner-e597
```

宿主目录由 docker 自动创建，删容器后目录保留。

## 配置（.env）

```
RUNNER_COUNT=2
RUNNER_NAME_PREFIX=docker-runner
RUNNER_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ORG_NAME=bwq-tech
RUNNER_SCOPE=org
RUNNER_GROUP=default
LABELS=self-hosted,linux,bwq-tech
RUNNER_IMAGE=myoung34/github-runner:latest
```

`RUNNER_TOKEN` 从 GitHub 的 Settings → Actions → Runners → New runner 里取，有效期约 1 小时，过期后容器会反复重启并打印 `401`/`Could not create registration token`，重取一次再跑 `sh setup.sh` 即可。

想省掉反复换 token，可以把 `-e RUNNER_TOKEN=...` 换成 `-e ACCESS_TOKEN=<org 级 PAT>`，但 PAT 权限更大，按需取舍。

## 注意

- `clear.sh` 按 `^${RUNNER_NAME_PREFIX}-` 前缀删容器，不碰其他容器。
- 4 位随机后缀在数量很多时可能撞名，撞了 docker 会报 name already in use，重跑即可。
- 宿主目录落在 `containers/gh-runner/<容器名>`，由 docker 自动创建，删容器后保留。
