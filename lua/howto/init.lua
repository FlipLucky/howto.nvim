-- howto.nvim: find Neovim keys, commands and recipes by intent.
-- This module stays tiny: setup() only stores the user's table; content and UI load on first open.
local M = {}

M.opts = { nodes = {}, entries = {} }

---@param opts? { nodes?: table[], entries?: table[] }
function M.setup(opts)
    opts = opts or {}
    M.opts = { nodes = opts.nodes or {}, entries = opts.entries or {} }
    -- Only touch the registry when it was already loaded: setup() itself must stay free.
    if package.loaded["howto.registry"] then
        package.loaded["howto.registry"].reset()
    end
end

--- Open the browser, optionally at a path like "edit/delete/word".
---@param path? string
function M.open(path)
    require("howto.ui").open(path)
end

return M
