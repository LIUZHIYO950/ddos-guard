-- init_by_lua：启动时读取部署生成的随机密钥，存入共享内存
local f = io.open('/usr/local/openresty/nginx/conf/guard/secret.key', 'rb')
if f then
    local s = f:read('*a')
    f:close()
    if s and #s > 0 then
        ngx.shared.guard_breaker:set('guard_secret', s)
    end
end
