# 发布到 GitHub 完整教程

> 目标：把 LADS 项目发布到 GitHub，展示为专业开源项目。
> 前置：一个 GitHub 账号（github.com 注册）。国内网络访问 GitHub 不稳定，建议全程开启代理。

---

## 一、修改占位内容（发布前必做）

发布前请把以下占位符替换成你自己的信息：

| 文件 | 占位符 | 替换为 |
|------|--------|--------|
| `README.md` | `<YOUR_GITHUB_USERNAME>` | 你的 GitHub 用户名（出现 2 处，徽章链接里） |
| `SECURITY.md` | `security@example.com` | 你的真实邮箱 |

## 二、在 GitHub 上创建仓库

1. 登录 GitHub → 右上角 `+` → **New repository**
2. 填写：
   - Repository name: `ddos-guard`
   - Description: `Lightweight DDoS protection layer based on OpenResty`
   - 可见性：Public（开源公开）或 Private（仅自己可见）
3. **不要勾选** "Add a README file"（避免与本地上传冲突）
4. 点击 **Create repository**

创建完成后页面会显示空仓库的推送命令，先别执行，看下面。

## 三、本地 Git 推送到 GitHub

在装有本发布包的机器上执行（命令可在手机终端/电脑终端跑）：

```bash
# 1. 进入项目目录
cd lads-publish          # 发布包解压后的目录

# 2. 初始化 git 仓库
git init

# 3. 把全部文件加入暂存区（.gitignore 会自动排除密钥等敏感文件）
git add .

# 4. 首次提交
git commit -m "feat: LADS v1.0.0"

# 5. 主分支命名为 main
git branch -M main

# 6. 关联远程仓库（替换为你的用户名）
git remote add origin https://github.com/<你的用户名>/ddos-guard.git

# 7. 推送
git push -u origin main
```

### 推送时如果要求认证

- 推荐用 GitHub CLI（首次使用需登录一次）：
  ```bash
  # 安装 gh（Mac: brew install gh；Win: winget install GitHub.cli；Linux: 见官方文档）
  gh auth login
  gh repo view ddos-guard --web
  ```
- 或使用 Personal Access Token：GitHub → Settings → Developer settings → Personal access tokens → Generate new token（勾选 repo 权限）→ push 时用户名填 GitHub 用户名、密码填 token。

### 推送失败怎么办

| 现象 | 处理 |
|------|------|
| `Could not resolve host github.com` | 网络问题，开启代理后重试 |
| `Authentication failed` | 用 token 或 `gh auth login` 重新认证 |
| `failed to push some refs` | 远程已有内容，先 `git pull --rebase origin main` 再 push |

## 四、启用 CI 检查（让项目更专业）

1. 推送后打开仓库页面 → **Actions** 标签
2. 会自动发现 `.github/workflows/lint.yml`（Lua + Shell 语法检查工作流）
3. 首次需要手动确认：Actions 页点击 **I understand my workflows, go ahead and enable them**
4. 工作流会在每次 push/PR 时自动跑语法检查，全绿显示 ✅

## 五、发布 Release（v1.0.0 正式版）

发布包（`lads-lads-publish.tar.gz`）作为 Release 附件，方便用户直接下载部署：

```bash
# 1. 打版本标签
git tag v1.0.0
git push origin v1.0.0
```

然后在网页上：

1. 仓库页 → 右侧 **Releases** → **Create a new release**
2. Tag 选择 `v1.0.0`
3. 标题：`v1.0.0`
4. 说明：复制 `CHANGELOG.md` 中 [1.0.0] 部分内容
5. **Attach binaries**：上传 `lads-lads-publish.tar.gz`
6. 点击 **Publish release**

发布后，用户可在 Releases 页面直接下载部署包。

## 六、完善仓库门面（可选但强烈建议）

1. **Topics**：仓库页右侧 Add topics，填 `ddos`、`security`、`openresty`、`nginx`、`waf` —— 便于被搜索到
2. **About 区**：补上 Website 或 Description
3. **Watch/Star/Fork** 数起来后，README 徽章会自动显示 CI 状态
4. **README 中的徽章链接**：推送到 GitHub 后，把 `<YOUR_GITHUB_USERNAME>` 替换为真实用户名，再 commit 一次即可点亮徽章

## 七、后续维护规范

| 场景 | 操作 |
|------|------|
| 修 bug | `git checkout -b fix/xxx` → 改代码 → PR 合并 |
| 发新版本 | 更新 `CHANGELOG.md` → commit → `git tag vX.Y.Z` → push → 建 Release |
| 收 Issue | 在仓库 Issues 标签回复；安全漏洞走 `SECURITY.md` 邮箱 |
| 收 PR | 检查 CI 是否通过 → 本地验证 → Merge |

## 八、发布前自检清单

- [ ] README 中的 GitHub 用户名占位符已替换
- [ ] SECURITY.md 邮箱已替换
- [ ] LICENSE 版权声明符合预期（默认 MIT，作者为 Contributors）
- [ ] 本地 `luac -p lua/*.lua` 与 `bash -n deploy.sh` 通过（CI 也会自动检查）
- [ ] 没有把 `secret.key` 等敏感文件加入版本库（.gitignore 已处理）
- [ ] 已用 `git add .` 前先 `git status` 确认暂存内容
