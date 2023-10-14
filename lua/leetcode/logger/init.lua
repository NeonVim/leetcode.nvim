local n_ok, notify = pcall(require, "notify")
if n_ok then vim.notify = notify end

local config = require("leetcode.config")
local lvls = vim.log.levels

---@class lc.Logger
local logger = {}

local function normalize(msg) return type(msg) == "string" and msg or vim.inspect(msg) end

---@param msg any
---@param lvl? integer
---@return any
logger.log = function(msg, lvl)
    if not config.user.logging then return msg end

    vim.notify(normalize(msg), lvl or lvls.INFO, { title = config.name })
    return msg
end

---@param msg any
---@return any
logger.info = function(msg) return logger.log(msg) end

---@param msg any
---@return any
logger.warn = function(msg) return logger.log(msg, lvls.WARN) end

---@param msg any
---@return any
logger.error = function(msg) return logger.log(msg, lvls.ERROR) end

---@param msg any
---@return any
logger.debug = function(msg)
    if not config.debug then return msg end

    logger.log(debug.traceback(normalize(msg) .. "\n"), lvls.DEBUG)
    return msg
end

return logger
