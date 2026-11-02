# LADS 主配置（由 deploy.sh 渲染生成）
user  openresty;
worker_processes  auto;
error_log  __NGINX_ROOT__/logs/error.log warn;
pid        __NGINX_ROOT__/logs/nginx.pid;

events {
    worker_connections  65535;
    multi_accept on;
    use epoll;
}

http {
    include       __NGINX_ROOT__/conf/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  __NGINX_ROOT__/logs/access.log  main;

    sendfile        on;
    tcp_nopush      on;
    keepalive_timeout  65;
    server_tokens   off;

    # ---- 传输层防慢速攻击 ----
    client_body_timeout 10s;
    client_header_timeout 10s;
    send_timeout 10s;

    # ---- Lua 模块路径与共享内存 ----
    lua_package_path  '__NGINX_ROOT__/conf/guard/lua/?.lua;;';
    lua_shared_dict   guard_breaker  16m;   # 全局熔断计数 + 密钥
    lua_shared_dict   guard_rate     16m;   # 单 IP 限流 + 黑名单
    init_by_lua_file  __NGINX_ROOT__/conf/guard/lua/init.lua;

    include __NGINX_ROOT__/conf/guard/conf/site.conf;
}
