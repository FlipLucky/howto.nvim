-- Is a native key mapped to something else in this setup? Then howto says so instead of
-- teaching a key that does something different here.
local M = {}

local runtime = vim.env.VIMRUNTIME and vim.fs.normalize(vim.env.VIMRUNTIME) or nil

local function source_of(m)
    if not m.callback then
        return nil
    end
    local info = debug.getinfo(m.callback, "S")
    local src = info and info.source or ""
    return (src:gsub("^@", ""))
end

-- Mappings Neovim creates itself (default-mappings, LSP/treesitter defaults).
local function is_default(m)
    if m.desc and m.desc:match("^:help .*%-default$") then
        return true
    end
    local function in_runtime(path)
        return runtime ~= nil and path ~= nil and vim.startswith(vim.fs.normalize(path), runtime)
    end
    local src = source_of(m)
    if src and (src:find("vim/_core/defaults", 1, true) or src:find("vim/_defaults", 1, true)) then
        return true
    end
    -- Set by a script that ships with Neovim (e.g. matchit's %).
    if m.sid and m.sid > 0 then
        local info = vim.fn.getscriptinfo({ sid = m.sid })[1]
        return info ~= nil and in_runtime(info.name)
    end
    -- A runtime callback set from Lua outside any script: Neovim's own (e.g. LSP's buffer-local K).
    -- (A runtime function mapped from the user's init.lua has that script's sid, so it isn't caught here.)
    return m.sid == -8 and in_runtime(src)
end

-- Which plugin (runtimepath entry) a file belongs to; "your config" for the config dir.
local function owner_of(path)
    if not path or path == "" then
        return nil
    end
    -- Resolve symlinks: a stowed ~/.config/nvim points into a dotfiles repo.
    local function real(p)
        p = vim.fs.normalize(vim.fn.fnamemodify(p, ":p"))
        return vim.fs.normalize(vim.uv.fs_realpath(p) or p)
    end
    path = real(path)
    local config = real(vim.fn.stdpath("config"))
    if vim.startswith(path, config .. "/") then
        return "your config"
    end
    local best
    for _, rtp in ipairs(vim.api.nvim_list_runtime_paths()) do
        rtp = real(rtp)
        if vim.startswith(path, rtp .. "/") and (not best or #rtp > #best) then
            best = rtp
        end
    end
    if best and not (runtime and best == runtime) then
        return vim.fs.basename(best)
    end
    return nil
end

local function origin(m)
    local src = source_of(m)
    local o = owner_of(src)
    if o then
        return o
    end
    if m.sid and m.sid > 0 then
        local info = vim.fn.getscriptinfo({ sid = m.sid })[1]
        return info and owner_of(info.name) or nil
    end
    return nil
end

--- For a native key entry: nil when the key does what howto says, otherwise
--- { what = "what it runs here", from = "plugin name" | "your config" | nil }.
---@param entry table
---@param buf integer the buffer the user came from (buffer-local mappings count)
function M.check(entry, buf)
    if entry.kind ~= "keys" or entry.source ~= "native" or entry.keys:find("{", 1, true) then
        return nil
    end
    local mode = entry.mode or "n"
    local m
    local ok = pcall(vim.api.nvim_buf_call, buf, function()
        m = vim.fn.maparg(entry.keys, mode, false, true)
    end)
    if not ok or not m or not m.lhs or is_default(m) then
        return nil
    end
    local what
    if m.rhs and m.rhs:lower() == "<nop>" then
        what = "does nothing (disabled)"
    else
        what = m.desc or m.rhs or "a Lua function"
    end
    return { what = what, from = origin(m) }
end

return M
