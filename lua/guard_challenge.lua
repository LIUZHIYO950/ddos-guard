-- 识别层：JS 挑战（Proof-of-Work）+ 无状态 HMAC 签名
-- 浏览器自动执行 JS 算题（毫秒级，用户无感）；DDoS 脚本默认不执行 JS，永远拿不到 Cookie
local common = require "guard_common"
local M = {}

local DIFFICULTY = 4     -- SHA1 前缀 0 位数（期望约 16 次尝试）
local NONCE_TTL = 60     -- 挑战题有效期（秒）

local html_tpl

local function load_html()
    if html_tpl then return html_tpl end
    local path = '/usr/local/openresty/nginx/conf/guard/html/challenge.html'
    local f = io.open(path, 'rb')
    if not f then
        html_tpl = '<h1>challenge unavailable</h1>'
        return html_tpl
    end
    html_tpl = f:read('*a')
    f:close()
    return html_tpl
end

-- 生成无状态挑战题：base64url(ip) . ts . base64url(hmac(ip.ts))
function M.make_nonce(ip)
    local ts = tostring(ngx.time())
    local payload = common.b64url(ip) .. '.' .. ts
    local sig = common.b64url(common.hmac(payload))
    return payload .. '.' .. sig
end

-- 验证挑战题：签名 + IP 匹配 + 60 秒有效期（防预计算批量绕过）
function M.verify_nonce(nonce, ip)
    local p1, ts, sig = nonce:match('^([^.]+)%.([^.]+)%.([^.]+)$')
    if not p1 then return false end
    local raw_ip = common.unb64url(p1)
    if not raw_ip or raw_ip ~= ip then return false end
    local t = tonumber(ts)
    if not t or t < ngx.time() - NONCE_TTL then return false end
    local expect = common.b64url(common.hmac(p1 .. '.' .. ts))
    return expect == sig
end

local function sha1_hex(s)
    local bin = ngx.sha1_bin(s)
    return (bin:gsub('.', function(c) return string.format('%02x', c:byte()) end))
end

-- 验证解题结果：sha1(nonce .. proof) 前 DIFFICULTY 位为 0
function M.verify_proof(nonce, proof, ip)
    if not M.verify_nonce(nonce, ip) then return false end
    local p = tostring(proof)
    if #p > 12 then return false end
    local digest = sha1_hex(nonce .. p)
    local target = string.rep('0', DIFFICULTY)
    return digest:sub(1, DIFFICULTY) == target
end

-- 输出挑战页（浏览器自动算题后回跳 /challenge/verify）
function M.render(ip)
    local nonce = M.make_nonce(ip)
    local back = ngx.var.uri
    if ngx.var.args and ngx.var.args ~= '' then
        back = back .. '?' .. ngx.var.args
    end
    local tpl = load_html()
    tpl = tpl:gsub('__NONCE__', nonce)
    tpl = tpl:gsub('__DIFF__', tostring(DIFFICULTY))
    tpl = tpl:gsub('__BACK__', back:gsub('%%', '%%%%'))
    ngx.header.content_type = 'text/html; charset=utf-8'
    ngx.say(tpl)
end

return M
