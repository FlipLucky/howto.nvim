local M = {}

function M.check()
    local h = vim.health
    h.start("howto")
    if vim.fn.has("nvim-0.10") == 0 then
        h.error("Neovim 0.10 or newer is required")
    end
    local tree = require("howto.registry").build()
    local entries = 0
    for _, node in pairs(tree.nodes) do
        entries = entries + #node.entries
    end
    h.ok(("%d intents, %d entry placements"):format(#tree.root.children, entries))
    if #tree.packs > 0 then
        h.ok("packs for installed plugins: " .. table.concat(tree.packs, ", "))
    else
        h.info("no packs active (none of the plugins with a pack is installed)")
    end
    if #tree.problems == 0 then
        h.ok("no invalid content")
    end
    for _, p in ipairs(tree.problems) do
        h.warn(p)
    end
end

return M
