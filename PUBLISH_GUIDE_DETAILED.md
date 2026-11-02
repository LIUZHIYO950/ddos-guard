# 小白零基础 GitHub 发布完全教程（LADS）

> 从零开始，每一步都写清楚：打开什么、点什么、填什么、看到什么算成功。
> 你的账号信息已预填，照着做即可。

## 你的账号信息（已替你填好）

| 项目 | 内容 |
|------|------|
| GitHub 用户名 | `liuzhiyo950` |
| 昵称 | 刘之遥 |
| 邮箱 | `3986095470@qq.com` |
| 仓库地址 | `https://github.com/liuzhiyo950/ddos-guard` |

---

## 第 0 步：准备工作

你需要：

1. **一台电脑**（Windows / Mac / Linux 都行，推荐用电脑操作，手机操作较麻烦）
2. **能稳定访问 GitHub**（你已满足。GitHub 页面是英文，用浏览器翻译功能翻译成中文，教程里会标注英文按钮名方便对照）
3. **发布包**：`lads-lads-publish.tar.gz`（已发给你，先放到电脑上）

---

## 第 1 步：注册 GitHub 账号（已有账号可跳过）

1. 浏览器打开 `https://github.com`
2. 点右上角绿色按钮 **Sign up**（注册）
3. 按提示填写：
   - Email（邮箱）：`3986095470@qq.com`
   - Password（密码）：自己设一个，建议记到备忘录
   - Username（用户名）：`liuzhiyo950`
4. 完成人机验证（勾选 "Verify" 或拼图片单词）
5. GitHub 会往你邮箱发一封验证邮件，打开邮箱点邮件里的 **Verify email address** 按钮
6. 回到 GitHub 页面，看到首页带你的头像，注册完成

---

## 第 2 步：安装 Git（电脑上的版本管理工具）

GitHub 是云端仓库，**Git** 是电脑本地工具，两者配合使用。

### Windows 电脑

1. 浏览器打开 `https://git-scm.com/downloads`
2. 点下载（Download 按钮），双击安装包
3. 一路点 **Next**（下一步），全部用默认选项，最后点 **Install**（安装）
4. 安装完成后，按 `Win` 键，搜索 **Git Bash**，回车打开一个黑色窗口
5. 在窗口里输入 `git --version` 回车，能看到版本号（如 `git version 2.4x.x`）即成功

### Mac 电脑

1. 按 `Command + 空格`，搜索 **Terminal**（终端），回车打开
2. 输入 `git --version` 回车
3. 如果提示没有 git，按提示安装（输入 `xcode-select --install` 回车，按引导完成；或已装 Homebrew 就输入 `brew install git`）
4. 再次输入 `git --version` 看到版本号即成功

### Linux 电脑

打开终端，执行（任选你的系统对应命令）：

```bash
sudo apt install -y git      # Debian/Ubuntu
sudo yum install -y git      # CentOS/RHEL
```

验证：`git --version` 看到版本号即成功

---

## 第 3 步：告诉 Git 你是谁（只做一次）

打开 Git Bash（Windows）或终端（Mac/Linux），**逐行**输入下面两行（已替你填好）：

```bash
git config --global user.name "刘之遥"
git config --global user.email "3986095470@qq.com"
```

每行输完按回车。没有任何提示 = 成功。
这两条命令让 Git 知道"提交者是谁"，以后每次提交都会记录你的名字。

---

## 第 4 步：解压发布包

1. 把 `lads-lads-publish.tar.gz` 放到电脑上（比如放到桌面）
2. 解压：
   - **Windows**：右键文件 → **全部解压**（Extract All）→ 选个位置 → 解压
   - **Mac**：双击文件自动解压
   - **Linux**：`tar -xzf lads-lads-publish.tar.gz`
3. 解压后得到一个文件夹 `lads-publish`，里面有 `README.md`、`deploy.sh`、`lua` 等

---

## 第 5 步：打开命令行并进入项目文件夹

### Windows 方法 A（最简单）

1. 打开 `lads-publish` 文件夹
2. 在文件夹地址栏（顶部显示路径的地方）输入 `cmd` 回车
3. 弹出黑色命令行窗口，路径已经在这个文件夹里，直接跳到第 6 步

### Windows 方法 B（Git Bash）

1. 打开 `lads-publish` 文件夹
2. 在文件夹空白处**右键** → 选择 **Git Bash Here**
3. 弹出 Git Bash 窗口，直接跳到第 6 步

### Mac / Linux

```bash
cd 你的lads-publish文件夹路径
```

（拖拽文件夹到终端窗口可自动填入路径）

### 确认位置正确

输入 `ls` 回车，能看到 `deploy.sh`、`README.md`、`lua` 等文件，说明位置正确。

---

## 第 6 步：创建 GitHub 仓库（网页操作）

1. 浏览器打开 `https://github.com`，确认已登录
2. 点右上角 **+** 号 → **New repository**（新建仓库）
3. 页面里填写：
   - **Repository name**（仓库名）：输入 `ddos-guard`（只能英文/数字/横线）
   - **Description**（简介，选填）：输入 `Lightweight DDoS protection layer based on OpenResty`
   - **Public / Private**：选 **Public**（公开，别人能看到；选 Private 则只有你自己能看）
   - 下面四个勾选框（Add a README file、Add .gitignore、Choose a license）**全部不要勾**
4. 点绿色按钮 **Create repository**（创建仓库）
5. 成功后页面跳到新仓库，地址栏显示：`https://github.com/liuzhiyo950/ddos-guard`
6. 页面中间会有一段"…or create a new repository on the command line"的命令，**先别复制执行**，用下面第 7 步的命令

---

## 第 7 步：把本地文件推送到 GitHub（核心步骤）

回到第 5 步打开的命令行窗口，**按顺序**执行下面 7 条命令，每条回车，看到成功提示再执行下一条：

### 命令 1：初始化仓库

```bash
git init
```

成功标志：出现 `Initialized empty Git repository in ...` 提示。

### 命令 2：把文件夹里所有文件加入待提交名单

```bash
git add .
```

（`.` 表示全部文件。没有任何提示 = 成功）

### 命令 3：（可选）查看待提交的文件清单

```bash
git status
```

会列出绿色文件列表，确认**没有** `secret.key`（那是服务器密钥，不能上传；`.gitignore` 已自动排除）。看到文件列表即可继续。

### 命令 4：提交快照

```bash
git commit -m "feat: LADS v1.0.0"
```

成功标志：出现 `1 file changed` 或 `create mode` 等提示。`-m` 后面引号里是本次提交说明（自己起也行，建议英文）。

### 命令 5：把主分支命名为 main

```bash
git branch -M main
```

（通常没有提示 = 成功）

### 命令 6：关联远程仓库（地址已替你填好）

```bash
git remote add origin https://github.com/liuzhiyo950/ddos-guard.git
```

（没有提示 = 成功）

### 命令 7：推送到 GitHub

```bash
git push -u origin main
```

这一步**第一次会要求登录**，有两种情况：

**情况 A（推荐）：弹出浏览器登录窗口**
- 浏览器会打开 GitHub 登录页，登录后回到命令行，自动继续推送

**情况 B：命令行提示输入 Username / Password**
- Username：输入 `liuzhiyo950`
- Password：**不要输登录密码**，要输 Personal Access Token（个人访问令牌），生成方法：
  1. 浏览器打开 `https://github.com/settings/tokens`（或：头像 → Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token）
  2. 填 Note（说明）：随意写 `ddos-guard`
  3. Expiration（有效期）：选 `No expiration` 或 90 days
  4. 勾选 **repo**（第一项大勾）
  5. 点 **Generate token**（生成令牌）
  6. 复制生成的 `ghp_` 开头的长串字符，**马上粘到命令行 Password 处**（粘贴后不回显是正常的）
  7. 注意：这个 token 只显示一次，记得存到备忘录；丢了就重新生成

### 成功标志

命令行出现类似：

```
To https://github.com/liuzhiyo950/ddos-guard.git
 * [new branch]      main -> main
```

然后刷新浏览器里 `https://github.com/liuzhiyo950/ddos-guard` 页面，看到 README.md、deploy.sh、lua 等文件列表 —— **发布成功！**

---

## 第 8 步：报错对照表（遇到问题先看这里）

| 报错信息 | 原因 | 解决办法 |
|----------|------|----------|
| `fatal: not a git repository` | 没执行 `git init`，或不在项目文件夹里 | 确认位置在 `lads-publish` 文件夹，重新执行 `git init` |
| `fatal: 'origin' does not appear...` | 第 6 条命令没执行成功 | 重新执行 `git remote add origin https://github.com/liuzhiyo950/ddos-guard.git` |
| `failed to push some refs` | 远程仓库已有内容（比如你勾了 README） | 执行 `git pull --rebase origin main` 后再 `git push -u origin main` |
| `remote: Repository not found` | 仓库地址打错，或仓库还没创建 | 确认第 6 步创建成功，检查地址拼写 |
| `Authentication failed` | 密码处填了登录密码而不是 token | 用第 7 步"情况 B"的方法生成 token 再推送 |
| `OpenSSL SSL_read: Connection was reset` | 网络问题 | 开启代理后重试 |

---

## 第 9 步：启用 CI 自动检查（专业感来源）

1. 打开仓库页面 `https://github.com/liuzhiyo950/ddos-guard`
2. 点顶部 **Actions**（操作）标签
3. 页面显示一个 workflow 叫 **lint**（语法检查），点绿色按钮 **I understand my workflows, go ahead and enable them**（我了解这些工作流，继续启用）
4. 进入后能看到检查在跑，几秒后变绿色 ✅（勾号）表示通过
5. 以后每次提交/合并 PR，都会自动检查 Lua 和 Shell 语法，全部通过才显示绿色

---

## 第 10 步：发布 Release 正式版（用户可下载部署包）

1. 回到命令行，执行：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
   （打版本标签并推送，没有报错即成功）

2. 打开仓库页面 → 右侧 **Releases**（发布）→ 绿色按钮 **Create a new release**（创建新发布）

3. 填写发布信息：
   - **Choose a tag**（选择标签）：选 `v1.0.0`
   - **Release title**（标题）：填 `v1.0.0`
   - 正文：复制 `CHANGELOG.md` 里的 [1.0.0] 内容
   - **Attach binaries**（附加文件）：把 `lads-lads-publish.tar.gz` 文件**拖进来**上传
4. 点 **Publish release**（发布）

发布后，别人打开仓库的 Releases 页面就能直接下载部署包。

---

## 第 11 步：完善仓库门面（可选但建议）

### 1. 点亮 README 徽章
README.md 里的徽章链接我已经替你替换成 `liuzhiyo950`，推到 GitHub 后 CI 徽章会自动变绿 ✅。

### 2. 加 Topics 标签（让项目容易被搜到）
仓库主页右侧 → **About** 区域 → 齿轮图标 → **Add topics** → 依次添加：
`ddos`、`security`、`openresty`、`nginx`、`waf` → **Save**

### 3. SECURITY.md 邮箱
已替你替换为 `3986095470@qq.com`，发现漏洞的访客会邮件联系你。

---

## 第 12 步：以后日常怎么更新

```bash
# 修改代码后，三步提交：
git add .
git commit -m "写清楚你改了啥"
git push

# 发新版本时：
git tag v1.1.0
git push origin v1.1.0
# 然后网页 Releases → 新建 Release 选新 tag、上传新压缩包
```

---

## 第 13 步：安全提醒（很重要）

1. **`secret.key` 永远不要提交**：这是服务器 HMAC 密钥，一旦公开任何人都能伪造"合法用户"身份。`.gitignore` 已自动排除，每次 `git status` 时留意即可
2. **GitHub token 不要发给任何人**，也别贴到公开地方
3. 账号开启两步验证（Settings → Password and authentication → Enable two-factor authentication）更安全
