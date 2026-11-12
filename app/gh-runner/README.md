# gh-runner

批量创建使用 Sysbox runtime 的 GitHub Actions Runner；清理时先注销，再删除容器。

## 用法

```bash
cd app/gh-runner
cp .env.example .env      # 填写令牌和组织信息
sh setup.sh               # 按 RUNNER_COUNT 创建
sh clear.sh               # 注销并删除本应用的 runner 容器
```

## 配置（.env）

```dotenv
RUNNER_COUNT=2
RUNNER_NAME_PREFIX=docker-runner
RUNNER_TOKEN=
ACCESS_TOKEN=
ORG_NAME=bwq-tech
RUNNER_SCOPE=org
RUNNER_GROUP=default
LABELS=self-hosted,linux,bwq-tech
START_DOCKER_SERVICE=false
RUNNER_IMAGE=myoung34/github-runner:latest
```

`setup.sh` 按变量是否有值决定是否传入 `RUNNER_TOKEN`、`ACCESS_TOKEN`：

- `RUNNER_TOKEN`：从 GitHub 的 New runner 页面获取，有效期约 1 小时。它过期不会中断正在运行的 runner，但当前镜像配置在容器重启时会重新注册，需要有效令牌。
- `ACCESS_TOKEN`：使用 Fine-grained PAT，Resource owner 选择目标组织，Organization permissions 授予 **Self-hosted runners → Read and write**。镜像用它获取短期注册令牌；设置有效期，到期前更换，组织要求审批时需先获批。
- 创建 runner 时两种令牌任选其一；同时填写时，镜像优先使用 `ACCESS_TOKEN`。`clear.sh` 必须使用有效的 `ACCESS_TOKEN`，也能清理之前用 `RUNNER_TOKEN` 创建的容器。

令牌仅填写在本地 `.env`，不要提交到 Git。修改 `.env` 仅影响后续新建的容器，不会改变已有容器的环境或 runtime；已有实例需要重建才能应用新配置。再次执行 `setup.sh` 会新增 runner，不会替换旧实例。`clear.sh` 使用当前 `.env` 中的凭据。

## Sysbox 与 Docker

请先按[官方安装说明](https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install-package.md)在宿主机手动安装 Sysbox。`setup.sh` 仅检查 Docker 是否已注册 `sysbox-runc` runtime；未检测到时提示安装并退出，不自动安装或修改 Docker 配置。

所有新建 runner 都使用 `--runtime=sysbox-runc`，不启用 Docker 特权模式，也不挂载宿主 Docker socket。`START_DOCKER_SERVICE=false` 表示不启动容器内 Docker；需要 Docker 构建的 CI 或部署任务改为 `true`，由镜像启动容器内 Docker daemon（DinD）。

`--tmpfs /run:mode=755` 保留 `/run` 的临时文件系统行为：容器停止后清除 PID、socket 等运行状态，减少 DinD 重启时的残留；它不是 Sysbox 的必要条件。

当前仍是长期运行的 runner，使用自动重启和持久工作目录，不会在每个任务后销毁。Sysbox 不负责清除前一个任务的修改；CI 和持有部署凭据的 CD 应使用独立 runner 与工作目录。

## 清理流程

宿主机需要 `curl` 和 `jq`。当前清理脚本支持 GitHub.com 的组织级 runner（`RUNNER_SCOPE=org`）：

```text
查找本地容器 → 核对组织和名称 → 停止容器 → GitHub API 注销 → 删除容器
```

- `clear.sh` 按 `${RUNNER_NAME_PREFIX}-` 前缀筛选容器，核对组织、作用域和 runner 名后才清理。
- 先关闭自动重启并停止容器，再查询完整名称对应的 runner ID，调用 `DELETE /orgs/{ORG_NAME}/actions/runners/{runner_id}`。已停止的容器也能处理，无需进入容器执行命令。
- 正常停止可能已触发镜像自行注销；API 查询确认远端记录不存在时，直接删除容器。返回多条同名记录或查询结果异常时停止，不猜测要删除哪条。
- 清理会中断正在运行的任务，请在任务结束后执行。API 或 Docker 操作失败时停止，保留当前容器；若已经停机，则保持停止并关闭自动重启，修正问题后重跑 `clear.sh`。已经成功清理的容器不回滚。
- 宿主挂载目录保留。没有目标容器时再次执行会直接结束。

## 命名与目录

容器名和 runner 名均为 `${RUNNER_NAME_PREFIX}-<4位随机>`，例如 `docker-runner-e597`。

```text
RUNNER_WORKDIR = /data/runner/docker-runner-e597
宿主挂载       = containers/gh-runner/docker-runner-e597
```

宿主目录由 Docker 自动创建。随机后缀撞名时，Docker 会提示名称已存在，重新运行即可。
