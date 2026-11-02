-- 公共工具：Base64url / HMAC-SHA1 / 客户端 Cookie 签发与验证
-- 全程无状态：服务端不存会话，验证只有一次 HMAC 比较（纳秒级）
local M = {}

local TOKEN_TTL = 600   -- Cookie 有效期（秒），过期后重新挑战

-- Base64url 编码（URL 安全字符集）
function M.b64url(s)
    local b = ngx.encode_base64(s)
    b = b:gsub('+', '-'):gsub('/', '_'):gsub('=+$', '')
    return b
end

-- Base64url 解码
function M.unb64url(s)
    s = s:gsub('-', '+'):gsub('_', '/')
    local pad = (4 - #s % 4) % 4
    return ngx.decode_base64(s .. string.rep('=', pad))
end

-- 读取共享内存中的 HMAC 密钥
function M.secret()
    return ngx.shared.guard_breaker:get('guard_secret') or ''
end

function M.hmac(str)
    return ngx.hmac_sha1(M.secret(), str)
end

-- 获取客户端真实 IP（优先取 X-Forwarded-For 首段）
function M.get_ip()
    local fwd = ngx.var.http_x_forwarded_for
    if fwd then
        local first = fwd:match('^([^,]+)')
        if first and first ~= '' then return first end
    end
    return ngx.var.remote_addr or ''
end

-- 签发客户端 Cookie：base64url(ip.ts) . base64url(hmac(ip.ts))
function M.issue_token(ip)
    local payload = ip .. '.' .. tostring(ngx.time())
    local sig = M.b64url(M.hmac(payload))
    return M.b64url(payload) .. '.' .. sig
end

-- 验证客户端 Cookie：验签 + IP 匹配 + 有效期
function M.verify_token(token, ip)
    local body, sig = token:match('^([^.]+)%.([^.]+)$')
    if not body then return false end
    local payload = M.unb64url(body)
    if not payload then return false end
    local tip, ts = payload:match('^([^.]+)%.(%d+)$')
    if not tip or tip ~= ip then return false end
    local t = tonumber(ts)
    if not t or t < ngx.time() - TOKEN_TTL then return false end
    local expect = M.b64url(M.hmac(payload))
    return expect == sig
end

return M
