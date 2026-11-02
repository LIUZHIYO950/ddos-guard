-- 请求主流程（rewrite 阶段执行，拒绝即输出并终止；放行则继续代理）
-- 顺序：黑名单 → 持证放行 → 单IP限流 → 全局熔断 → 下发挑战
local common    = require "guard_common"
local breaker   = require "guard_breaker"
local rate      = require "guard_rate"
local challenge = require "guard_challenge"

local ip = common.get_ip()
if ip == '' then
    ip = 'unknown'
end

-- 1) 黑名单：直接拒绝
if rate.is_blocked(ip) then
    ngx.status = ngx.HTTP_SERVICE_UNAVAILABLE
    ngx.say('YISIDDOS')
    return ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
end

-- 2) 已持有有效签名 Cookie：放行（合法用户无感）
local token = ngx.var.cookie_guard_token
if token and common.verify_token(token, ip) then
    return
end

-- 3) 单 IP 限流：只拒绝攻击源
if rate.check(ip) then
    ngx.status = ngx.HTTP_TOO_MANY_REQUESTS
    ngx.say('YISIDDOS')
    return ngx.exit(ngx.HTTP_TOO_MANY_REQUESTS)
end

-- 4) 全局熔断：触发期间所有无证请求返回 YISIDDOS
if breaker.check() then
    ngx.status = ngx.HTTP_SERVICE_UNAVAILABLE
    ngx.say('YISIDDOS')
    return ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
end

-- 5) 未持证访客：下发 JS 挑战（浏览器自动执行，用户无感）
challenge.render(ip)
return ngx.exit(ngx.HTTP_OK)
