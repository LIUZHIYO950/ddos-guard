# 贡献指南

欢迎参与 LADS 的开发！任何形式的贡献都很有价值：报告问题、提交代码、完善文档、分享使用经验。

## 如何报告 Issue

- 先搜索 [Issues](https://github.com) 确认没有重复
- 标题简要描述问题，正文包含：
  - 环境：操作系统版本、OpenResty 版本（`openresty -v`）
  - 复现步骤
  - 期望行为与实际行为
  - 相关日志（`/usr/local/openresty/nginx/logs/error.log`）

## 如何提交 Pull Request

1. Fork 本仓库并克隆到本地
2. 创建功能分支：`git checkout -b feat/xxx`
3. 修改代码，遵循现有风格
4. 本地验证：
   ```bash
   # Lua 语法检查
   for f in lua/*.lua; do luac -p "$f"; done
   # 部署脚本语法检查
   bash -n deploy.sh
   ```
5. 提交并推送，创建 PR，描述改动内容与测试结果

## 代码规范

- Lua 使用 4 空格缩进，模块返回 `local M` 表
- 新增防护规则需在 `CHANGELOG.md` 记录
- 不引入第三方依赖（保持 OpenResty 内置 API 零依赖）
- 涉及安全改动必须补充说明攻击场景与验证方法

## 开发环境

- OpenResty 1.25+（自带 `ngx.sha1_bin` / `ngx.hmac_sha1` 等 API）
- 本地可用 `luac`（lua5.1）做语法检查
