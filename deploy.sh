#!/usr/bin/env bash
# ============================================================
#  LADS（简洁化中小型服务器攻击防御系统）一键部署脚本
#  用法: sudo bash deploy.sh [后端地址] [监听端口]
#  示例: sudo bash deploy.sh http://127.0.0.1:8080 80
#  默认: 后端 http://127.0.0.1:8080 ，监听 80 端口
# ============================================================
set -euo pipefail

BACKEND="${1:-http://127.0.0.1:8080}"
PORT="${2:-80}"
NGINX_ROOT="/usr/local/openresty/nginx"
LUA_DIR="$NGINX_ROOT/conf/guard"
NGINX_BIN="$NGINX_ROOT/sbin/nginx"
SECRET_FILE="$LUA_DIR/secret.key"

log() { echo -e "\033[1;32m[OK]\033[0m $1"; }
info() { echo -e "\033[1;36m[..]\033[0m $1"; }
die() { echo -e "\033[1;31m[ERR]\033[0m $1" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "请以 root 运行: sudo bash deploy.sh $*"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------- 1. 安装 OpenResty（若未安装） ----------
if [ ! -x "$NGINX_BIN" ]; then
  info "未检测到 OpenResty，开始安装..."
  . /etc/os-release
  case "$ID" in
    ubuntu|debian)
      apt-get update -y
      apt-get install -y wget gnupg ca-certificates
      wget -qO - https://openresty.org/package/pubkey.gpg | apt-key add - || true
      echo "deb http://openresty.org/package/ubuntu ${VERSION_CODENAME} main" \
        > /etc/apt/sources.list.d/openresty.list
      apt-get update -y
      apt-get install -y openresty || die "openresty 安装失败，请手动安装后重跑"
      ;;
    centos|rhel|tencentos|rocky|almalinux|anolis|openeuler|*)
      if command -v yum-config-manager >/dev/null 2>&1; then
        yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo || true
      elif command -v dnf >/dev/null 2>&1; then
        dnf config-manager --add-repo https://openresty.org/package/centos/openresty.repo || true
      else
        yum install -y yum-utils
        yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo || true
      fi
      (yum install -y openresty || dnf install -y openresty) \
        || die "openresty 安装失败，请手动安装后重跑"
      ;;
  esac
  [ -x "$NGINX_BIN" ] || die "OpenResty 未安装成功，请参考 https://openresty.org 手动安装"
fi
log "OpenResty 就绪: $($NGINX_BIN -v 2>&1)"

# ---------- 2. 拷贝防护文件 ----------
mkdir -p "$LUA_DIR"/{lua,html,conf}
cp -r "$SCRIPT_DIR/lua/"* "$LUA_DIR/lua/" 2>/dev/null || true
cp -r "$SCRIPT_DIR/html/"* "$LUA_DIR/html/" 2>/dev/null || true
log "防护 Lua/HTML 文件已就位 -> $LUA_DIR"

# ---------- 3. 生成随机密钥（已存在则保留） ----------
if [ ! -s "$SECRET_FILE" ]; then
  openssl rand -hex 32 > "$SECRET_FILE" 2>/dev/null \
    || head -c 64 /dev/urandom | od -An -tx1 | tr -d ' \n' > "$SECRET_FILE"
fi
chmod 600 "$SECRET_FILE"
log "HMAC 密钥已就绪: $SECRET_FILE"

# ---------- 4. 渲染站点配置 ----------
sed -e "s|__BACKEND__|$BACKEND|g" \
    -e "s|__PORT__|$PORT|g" \
    -e "s|__NGINX_ROOT__|$NGINX_ROOT|g" \
    "$SCRIPT_DIR/conf/site.conf.tpl" > "$LUA_DIR/conf/site.conf"
log "站点配置已渲染: 后端=$BACKEND 监听端口=$PORT"

# ---------- 5. 渲染并安装主配置（原配置自动备份） ----------
sed -e "s|__NGINX_ROOT__|$NGINX_ROOT|g" \
    "$SCRIPT_DIR/conf/nginx.conf.tpl" > "$LUA_DIR/conf/nginx.conf"
if [ -f "$NGINX_ROOT/conf/nginx.conf" ]; then
  cp "$NGINX_ROOT/conf/nginx.conf" "$NGINX_ROOT/conf/nginx.conf.bak.$(date +%Y%m%d%H%M%S)"
fi
cp "$LUA_DIR/conf/nginx.conf" "$NGINX_ROOT/conf/nginx.conf"
log "主配置已安装（原配置已备份）"

# ---------- 6. 配置测试并启动 ----------
"$NGINX_BIN" -t -p "$NGINX_ROOT/" || die "nginx 配置测试失败，请检查上面输出"
if "$NGINX_BIN" -p "$NGINX_ROOT/" -s stop >/dev/null 2>&1; then
  : # 已停止，等待重启
fi
"$NGINX_BIN" -p "$NGINX_ROOT/" || \
  "$NGINX_BIN" -p "$NGINX_ROOT/" -s reload || true
log "OpenResty 已启动/重载"

# ---------- 7. 完成提示 ----------
cat <<EOF

============================================================
  部署完成
------------------------------------------------------------
  入口地址   : http://<服务器IP>:${PORT}
  后端服务   : ${BACKEND}
  配置目录   : ${LUA_DIR}
  HMAC 密钥  : ${SECRET_FILE}
------------------------------------------------------------
  验证方式:
    curl -v http://127.0.0.1:${PORT}/     # 应返回挑战页 HTML
    curl -s http://127.0.0.1:${PORT}/     # 无 JS 脚本拿不到 Cookie，永远被挡
  压力测试:
    ab -n 5000 -c 200 http://127.0.0.1:${PORT}/  # 触发熔断后返回 YISIDDOS
------------------------------------------------------------
  卸载方式:
    还原备份: cp $NGINX_ROOT/conf/nginx.conf.bak.* $NGINX_ROOT/conf/nginx.conf
    删除目录: rm -rf ${LUA_DIR}
    重载生效: $NGINX_BIN -p $NGINX_ROOT/ -s reload
============================================================
EOF
