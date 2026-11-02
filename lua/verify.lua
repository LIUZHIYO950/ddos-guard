-- 挑战验证接口：/challenge/verify?proof=..&nonce=..&back=..
-- 验题通过 → 签发签名 Cookie → 302 回原页面
local common    = require "guard_common"
local challenge = require "guard_challenge"

local args = ngx.req.get_uri_args()
local proof = args.proof
local nonce = args.nonce
local back  = args.back or '/'

if not proof or not nonce then
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

local ip = common.get_ip()

if not challenge.verify_proof(nonce, proof, ip) then
    ngx.status = ngx.HTTP_FORBIDDEN
    ngx.say('challenge failed')
    return ngx.exit(ngx.HTTP_FORBIDDEN)
end

-- 签发 Cookie（HttpOnly，防 XSS 窃取；10 分钟有效期）
local token = common.issue_token(ip)
ngx.header['Set-Cookie'] = 'guard_token=' .. token ..
    '; Path=/; HttpOnly; Max-Age=600'

-- 回跳目标只允许站内路径（防开放重定向）
if back:sub(1, 1) ~= '/' or back:find('//') then
    back = '/'
end

return ngx.redirect(back, ngx.HTTP_MOVED_TEMPORARILY)
