-- A native entry whose key the user's config (or a plugin) maps to something else gets a notice,
-- so howto never silently teaches a key that does something different here.
local h = require("helpers")
local T = {}

T["a key remapped in the config shows what it does here"] = function()
    h.map("n", "<C-l>", "<cmd>echo 'pane'<cr>", { desc = "Move to the right pane" })
    h.open("search/file")
    h.select("<C-l>")
    local strip = h.strip()
    h.contains(strip, "remapped")
    h.contains(strip, "Move to the right pane")
end

T["a key disabled with <Nop> says it does nothing"] = function()
    h.map("n", "s", "<Nop>")
    h.open("edit/small")
    h.select("s ")
    h.contains(h.strip(), "does nothing")
end

T["a buffer-local mapping in the buffer you came from counts"] = function()
    h.map("n", "K", "<cmd>echo 'doc'<cr>", { buffer = 0, desc = "Plugin docs" })
    h.open("code/info")
    h.select("K ")
    h.contains(h.strip(), "Plugin docs")
end

T["a mapping from a plugin names the plugin"] = function()
    local dir = h.fake_plugin("fake-nav.nvim")
    vim.fn.mkdir(dir .. "/lua", "p")
    local f = assert(io.open(dir .. "/lua/fakenav.lua", "w"))
    f:write('return { setup = function() vim.keymap.set("n", "<C-l>", function() end, { desc = "Navigate right" }) end }')
    f:close()
    package.loaded.fakenav = nil
    require("fakenav").setup()
    table.insert(h.maps, { "n", "<C-l>" }) -- set by the fake plugin; clean up after this test
    h.open("search/file")
    h.select("<C-l>")
    h.contains(h.strip(), "fake-nav.nvim")
end

T["Neovim's own defaults are not reported"] = function()
    h.open("edit/yank/line")
    h.select("Y ")
    h.not_contains(h.strip(), "remapped")
end

T["no native entry is reported on a clean Neovim"] = function()
    -- This runs under `nvim --clean`: every mapping is a Neovim default, so any notice is a false alarm.
    local remap = require("howto.remap")
    local tree = require("howto.registry").build()
    local bad, seen = {}, {}
    for _, node in pairs(tree.nodes) do
        for _, e in ipairs(node.entries) do
            if not seen[e] then
                seen[e] = true
                local r = remap.check(e, vim.api.nvim_get_current_buf())
                if r then
                    table.insert(bad, (e.mode or "n") .. " " .. (e.keys or "?") .. " → " .. r.what)
                end
            end
        end
    end
    assert(#bad == 0, "false remap notices on a clean Neovim:\n" .. table.concat(bad, "\n"))
end

T["entries from packs and setup() are not checked"] = function()
    h.map("n", "zM1", "<cmd>echo 1<cr>", { desc = "my own" })
    require("howto").setup({ entries = { { keys = "zM1", at = "edit", label = "mine" } } })
    h.open("edit")
    h.select("zM1")
    h.not_contains(h.strip(), "remapped")
end

return T
