local config = require("leetcode.config")
local parser = require("leetcode.parser")

local Layout = require("leetcode-ui.layout")
local Text = require("leetcode-ui.component.text")
local padding = require("leetcode-ui.component.padding")

local NuiLine = require("nui.line")
local Split = require("nui.split")

---@class lc.Description
---@field split NuiSplit
---@field parent lc.Question
---@field content any
---@field title any
---@field layout lc-ui.Layout
---@field visible boolean
local description = {}
description.__index = description

local group_id = vim.api.nvim_create_augroup("leetcode_description", { clear = true })

function description:autocmds()
    vim.api.nvim_create_autocmd("WinResized", {
        group = group_id,
        buffer = self.split.bufnr,
        callback = function() self:draw() end,
    })
end

function description:mount()
    self.visible = true
    self:populate()
    self.split:mount()
    self:draw()

    local utils = require("leetcode-menu.utils")
    utils.apply_opt_local({
        buflisted = false,
        matchpairs = "",
        swapfile = false,
        buftype = "nofile",
        filetype = "leetcode.nvim",
        synmaxcol = 0,
        modifiable = false,
        wrap = true,
        colorcolumn = "",
        foldlevel = 999,
        foldcolumn = "1",
        cursorcolumn = false,
        cursorline = false,
        number = false,
        relativenumber = false,
        list = false,
        spell = false,
        signcolumn = "no",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
    })

    self:autocmds()
    return self
end

function description:toggle()
    if self.visible then
        self.split:hide()
    else
        self.split:show()
    end

    self.visible = not self.visible
end

function description:draw()
    local c = vim.api.nvim_win_get_cursor(self.split.winid)
    self.layout:draw(self.split)
    vim.api.nvim_win_set_cursor(self.split.winid, c)
end

-- function description:redraw()
--     local c = vim.api.nvim_win_get_cursor(self.split.winid)
--     self.layout:draw()
--     vim.api.nvim_win_set_cursor(self.split.winid, c)
-- end

---@private
function description:populate()
    local q = self.parent.q

    local linkline = NuiLine()
    linkline:append("https://leetcode.com/problems/" .. q.title_slug .. "/", "leetcode_alt")

    local titleline = NuiLine()
    titleline:append(" " .. q.frontend_id .. ". " .. q.title .. " ", "")

    local statsline = NuiLine()
    statsline:append(
        q.difficulty,
        ({
            ["Easy"] = "leetcode_easy",
            ["Medium"] = "leetcode_medium",
            ["Hard"] = "leetcode_hard",
        })[q.difficulty]
    )
    statsline:append(" | ")

    statsline:append(q.likes .. "  ", "leetcode_alt")
    statsline:append(q.dislikes .. " ", "leetcode_alt")
    statsline:append(" | ")

    statsline:append(
        string.format("%s of %s", q.stats.acRate, q.stats.totalSubmission),
        "leetcode_alt"
    )
    if not vim.tbl_isempty(q.hints) then
        statsline:append(" | ")
        statsline:append("󰛨 Hints", "leetcode_alt")
    end

    local titlecomp = Text:init({
        lines = { titleline },
        opts = { position = "center" },
    })
    local statscomp = Text:init({
        lines = { statsline },
        opts = { position = "center" },
    })
    local linkcomp = Text:init({
        lines = { linkline },
        opts = { position = "center" },
    })

    local contents = parser:init(q.content, "html"):parse()

    self.layout = Layout:init({
        components = {
            linkcomp,
            padding:init(1),
            titlecomp,
            statscomp,
            padding:init(3),
            contents,
            padding:init(1),
        },
        opts = { margin = 5 },
    })
end

---@param parent lc.Question
function description:init(parent)
    local split = Split({
        relative = "editor",
        position = "left",
        size = config.user.description.width,
        enter = true,
        focusable = true,
    })

    local obj = setmetatable({
        split = split,
        parent = parent,
        layout = {},
        visible = false,
    }, self)

    -- vim.api.nvim_buf_set_name(obj.split.bufnr, string.format("Description(%s)", parent.q.title))

    return obj:mount()
end

return description
