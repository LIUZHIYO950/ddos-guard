-- 单 IP 限流 + 攻击源黑名单
-- 单 IP 每秒超过 IP_RATE 次 → 先返回 429；连续 BLOCK_OVER 个窗口超限 → 拉黑 60 秒
-- 只拒绝攻击源，不误伤其他用户
local M = {}

local dict = ngx.shared.guard_rate

local IP_RATE = 30        -- 单 IP 每秒请求上限
local BLOCK_OVER = 3      -- 连续超限窗口数阈值
local BLOCK_SECONDS = 60  -- 黑名单时长（秒）

-- 是否在黑名单中
function M.is_blocked(ip)
    local until_ts = dict:get('blocked:' .. ip)
    if until_ts and until_ts > ngx.now() then
        return true
    end
    return false
end

-- 限流检查：返回 true 表示应拒绝该 IP 的本次请求
function M.check(ip)
    local win_id = math.floor(ngx.now() / 1)   -- 1 秒固定窗口
    local key = 'ip:' .. ip .. ':' .. win_id
    local cur = dict:incr(key, 1, 1)
    if cur == 1 then
        dict:expire(key, 3)
    end

    if cur <= IP_RATE then
        return false
    end

    -- 超限：累计违规次数，连续多个窗口超限则拉黑
    local over = dict:incr('over:' .. ip, 1, 1)
    dict:expire('over:' .. ip, 5)
    if over >= BLOCK_OVER then
        dict:set('blocked:' .. ip, ngx.now() + BLOCK_SECONDS, BLOCK_SECONDS + 5)
        return true
    end
    return false
end

return M
