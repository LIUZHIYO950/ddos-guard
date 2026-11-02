---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: e667885c097870a75ee4ee7ba1652f07_b7520646d60a11f19fe5525400638852
    ReservedCode1: EBfniPcAQzgqXsypyoht8hPsc15PoU9gK0LB9xeRGhb/NJcLF6gjVpCDozx8rxtRS6/Jk948QWcdLZBTsWETmeKyOi8qXJJhRJY6qJms9WkyULS7dskMe282vXY/lWQYG9u178TC7VDTsN96UVEjkx2ECtFJW6qQoX9EMOI6cBeGVGpraGCV/OPcS9s=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: e667885c097870a75ee4ee7ba1652f07_b7520646d60a11f19fe5525400638852
    ReservedCode2: EBfniPcAQzgqXsypyoht8hPsc15PoU9gK0LB9xeRGhb/NJcLF6gjVpCDozx8rxtRS6/Jk948QWcdLZBTsWETmeKyOi8qXJJhRJY6qJms9WkyULS7dskMe282vXY/lWQYG9u178TC7VDTsN96UVEjkx2ECtFJW6qQoX9EMOI6cBeGVGpraGCV/OPcS9s=
---

# LADS 一键部署包

基于 OpenResty 的服务器防 DDoS 防护层：**任何服务器可部署、处理速度快、能区分合法用户与攻击脚本**。

## 功能一览

| 模块 | 作用 |
|---|---|
| 全局熔断（guard_breaker.lua） | 按你的档位检测：0.5s>150 / 1s>200 / 1.5s>250 / 2s>300 / 3s>1000，触发后熔断 30 秒 |
| 单 IP 限流（guard_rate.lua） | 单 IP 每秒 >30 次先 429，连续超限拉黑 60 秒，只拒攻击源 |
| 识别层（guard_challenge.lua） | 无 Cookie 访客下发 JS 挑战，浏览器自动算题换签名 Cookie；DDoS 脚本不会执行 JS，永远被挡 |
| 无状态签名（guard_common.lua） | HMAC-SHA1 签名 Cookie，服务端零存储，验证纳秒级，防伪造 |
| 挑战验证（verify.lua） | 验题通过签发 HttpOnly Cookie，防 XSS 窃取、防开放重定向 |
| 传输层保护（nginx.conf.tpl） | 连接数/速率/超时限制，防 Slowloris 慢速攻击 |

熔断期间：无证请求统一返回 **`YISIDDOS`**（HTTP 503/429），你的客户端软件可直接识别此响应提示用户。

## 目录结构

```
ddos-guard/
├── deploy.sh              # 一键部署入口（root 执行）
├── conf/
│   ├── nginx.conf.tpl     # 主配置模板（共享内存/传输层防护）
│   └── site.conf.tpl      # 站点配置模板（防护 + 反代）
├── lua/
│   ├── init.lua           # 启动时读取随机密钥
│   ├── flow.lua           # 请求主流程（黑名单→放行→限流→熔断→挑战）
│   ├── guard_breaker.lua  # 全局多窗口熔断
│   ├── guard_rate.lua     # 单 IP 限流 + 黑名单
│   ├── guard_challenge.lua# JS 挑战签发与验证
│   ├── guard_common.lua   # HMAC Cookie 工具
│   └── verify.lua         # 挑战验证接口
└── html/
    └── challenge.html     # 挑战页（内嵌 SHA1，零依赖）
```

## 部署

```bash
# 普通用法（默认反代本机 8080 端口，监听 80）
sudo bash deploy.sh

# 指定后端与端口
sudo bash deploy.sh http://127.0.0.1:3000 80
sudo bash deploy.sh http://192.168.1.10:8080 8080
```

脚本自动完成：安装 OpenResty → 生成随机 HMAC 密钥 → 渲染配置 → 备份原配置 → `nginx -t` 测试 → 启动。

## 验证

```bash
# 1) 正常访问：浏览器打开 http://<IP>:<端口>/ 会先看到挑战页，自动算题后进入业务
curl -v http://127.0.0.1:80/          # 返回挑战页 HTML，无 Cookie

# 2) 压测触发熔断（模拟 DDoS）：
ab -n 5000 -c 200 http://127.0.0.1:80/
# 熔断后响应体为 YISIDDOS，30 秒后自动恢复检测

# 3) 带 Cookie 的合法客户端不受熔断影响（熔断只拒绝无证请求）
```

## 调参位置

- 熔断档位 / 熔断时长：`lua/guard_breaker.lua` 顶部 `WINDOWS`、`BREAK_SECONDS`
- 单 IP 限流 / 拉黑阈值：`lua/guard_rate.lua` 顶部 `IP_RATE`、`BLOCK_OVER`、`BLOCK_SECONDS`
- 挑战难度：`lua/guard_challenge.lua` 顶部 `DIFFICULTY`（4 = 期望 16 次 SHA1；攻击时可调高）
- Cookie 有效期：`lua/guard_common.lua` 顶部 `TOKEN_TTL`

修改后执行 `sudo /usr/local/openresty/nginx/sbin/nginx -p /usr/local/openresty/nginx/ -s reload` 生效。

## 注意事项

1. **必须 root 运行**（安装软件 + 写 /usr/local）
2. **HTTPS**：建议再套一层 TLS（可用 certbot 或在本配置 server 块加证书），挑战页与 Cookie 走 HTTPS 更安全
3. **多实例**：多台服务器各自部署即可；如需全局统一熔断，把 `guard_breaker` 的计数换成 Redis（逻辑不变）
4. **带宽型超大攻击**：本方案保护的是"服务器还能收到请求"的场景；数十 Gbps 级流量攻击仍需上游高防/CDN
5. **卸载**：按 deploy.sh 末尾提示还原 nginx.conf 备份并删除 guard 目录

## 客户端对接

你的客户端软件请求服务器时：
- 正常响应 = 业务数据
- 响应体为 `YISIDDOS` 且状态码为 503/429 = 服务器疑似遭受 DDoS，提示用户"服务器疑似正在遭受DDOS攻击，请过一段时间后再次尝试"
*（内容由AI生成，仅供参考）*
