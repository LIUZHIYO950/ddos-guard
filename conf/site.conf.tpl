# LADS 站点配置（由 deploy.sh 渲染生成）
server {
    listen      __PORT__;
    server_name _;

    # 挑战验证接口：浏览器 JS 算题后回跳这里换取签名 Cookie
    location = /challenge/verify {
        content_by_lua_file __NGINX_ROOT__/conf/guard/lua/verify.lua;
    }

    # 受保护业务入口：所有请求先过防护层，通过后反代到后端
    location / {
        rewrite_by_lua_file __NGINX_ROOT__/conf/guard/lua/flow.lua;

        proxy_pass __BACKEND__;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 10s;
        proxy_read_timeout 30s;
    }
}
