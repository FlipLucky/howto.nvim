-- Test helpers: everything goes through what a user can see or do.
local M = {}

local base_rtp
function M.reset()
    base_rtp = base_rtp or vim.o.runtimepath
    vim.o.runtimepath = base_rtp
    pcall(vim.cmd, "silent! only!")
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative ~= "" then
            pcall(vim.api.nvim_win_close, win, true)
        end
    end
    for name in pairs(package.loaded) do
        if name == "howto" or name:match("^howto%.") or name:match("^fakepack") then
            package.loaded[name] = nil
        end
    end
    for _, m in ipairs(M.maps or {}) do
        pcall(vim.keymap.del, m[1], m[2], m[3])
    end
    M.maps = {}
    vim.o.columns, vim.o.lines = 120, 40
    M.notes = {}
    vim.notify = function(msg, level)
        table.insert(M.notes, { msg = msg, level = level })
    end
end

-- The howto float, or nil.
function M.win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "howto" then
            return win
        end
    end
end

-- Like vim.keymap.set, but removed again before the next test.
function M.map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts)
    table.insert(M.maps, { mode, lhs, opts and opts.buffer and { buffer = opts.buffer } or nil })
end

function M.open(path)
    require("howto").open(path)
    assert(M.win(), "howto window did not open")
end

function M.press(keys)
    vim.api.nvim_feedkeys(vim.keycode(keys), "mx", false)
end

function M.lines()
    local win = assert(M.win(), "howto is not open")
    return vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false)
end

function M.text()
    return table.concat(M.lines(), "\n")
end

function M.title()
    local t = vim.api.nvim_win_get_config(M.win()).title
    if type(t) == "table" then
        return table.concat(vim.tbl_map(function(c) return c[1] end, t))
    end
    return t or ""
end

-- The selected item of the focused column (the line part after the ▌ marker).
function M.selected()
    for _, l in ipairs(M.lines()) do
        local s = l:match("▌(.-)%s*│") or l:match("▌(.-)%s*$")
        if s then
            -- Recipes are shown as "⋯  label"; match them by label.
            return vim.trim((vim.trim(s):gsub("^⋯%s*", "")))
        end
    end
end

-- Move the cursor in the focused column down until the selected item starts with `prefix`.
function M.select(prefix)
    M.press("gg")
    for _ = 1, 80 do
        local s = M.selected()
        if s and vim.startswith(s, prefix) then
            return
        end
        M.press("j")
    end
    error("could not select an item starting with " .. vim.inspect(prefix) .. "\n" .. M.text())
end

-- Walk a path of item prefixes from the root: go("Edit", "d  delete", "w  word")
function M.go(...)
    for _, prefix in ipairs({ ... }) do
        M.select(prefix)
        M.press("l")
    end
end

-- Lines below the strip separator.
function M.strip()
    local out, seen = {}, false
    for _, l in ipairs(M.lines()) do
        if seen then
            table.insert(out, l)
        elseif l:match("^─+") then
            seen = true
        end
    end
    return table.concat(out, "\n")
end

function M.contains(haystack, needle, msg)
    if not haystack:find(needle, 1, true) then
        error((msg or "expected text not found") .. ": " .. vim.inspect(needle) .. "\n--- in:\n" .. haystack, 2)
    end
end

function M.not_contains(haystack, needle, msg)
    if haystack:find(needle, 1, true) then
        error((msg or "unexpected text found") .. ": " .. vim.inspect(needle) .. "\n--- in:\n" .. haystack, 2)
    end
end

function M.warnings()
    return table.concat(vim.tbl_map(function(n) return n.msg end, M.notes), "\n")
end

-- A throwaway plugin directory on the runtimepath (to make a pack's plugin "installed").
function M.fake_plugin(name)
    local dir = vim.fn.tempname() .. "/" .. name
    vim.fn.mkdir(dir, "p")
    vim.opt.rtp:append(dir)
    return dir
end

-- A pack module outside the plugin (as a third-party pack would be found on the runtimepath).
function M.fake_pack_dir(files)
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir .. "/lua/howto/packs", "p")
    for name, body in pairs(files) do
        local f = assert(io.open(dir .. "/lua/howto/packs/" .. name .. ".lua", "w"))
        f:write(body)
        f:close()
    end
    vim.opt.rtp:append(dir)
    return dir
end

return M
