-- 全局熔断检测：多窗口频率计数
-- 窗口阈值（沿用你定义的档位）：
--   0.5秒窗口超150次 / 1秒超200次 / 1.5秒超250次 / 2秒超300次 / 3秒超1000次
-- 任一窗口触发 → 熔断 30 秒；30 秒后若仍超阈值则继续熔断
local M = {}

local dict = ngx.shared.guard_breaker

local WINDOWS = {
    { 0.5, 150 },
    { 1.0, 200 },
    { 1.5, 250 },
    { 2.0, 300 },
    { 3.0, 1000 },
}
local BREAK_SECONDS = 30
local KEY_BREAKER = 'breaker_until'

-- 返回 true 表示当前处于熔断状态
function M.check()
    local now = ngx.now()

    -- 已在熔断中：直接拒绝，到期后由下次请求重新检测
    local until_ts = dict:get(KEY_BREAKER) or 0
    if until_ts > now then
        return true
    end

    -- 遍历各窗口计数（固定窗口 + 原子自增，无锁）
    local triggered = false
    for _, w in ipairs(WINDOWS) do
        local win  = w[1]
        local limit = w[2]
        local win_id = math.floor(now / win)
        local key = 'win:' .. win .. ':' .. win_id
        local cur = dict:incr(key, 1, 1)
        if cur == 1 then
            dict:expire(key, math.ceil(win * 2))   -- 窗口过期自动清理
        end
        if cur > limit then
            triggered = true
        end
    end

    if triggered then
        dict:set(KEY_BREAKER, now + BREAK_SECONDS, BREAK_SECONDS + 5)
        return true
    end
    return false
end

return M
