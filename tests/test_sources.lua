-- Where content comes from: native, packs, the user's setup().
local h = require("helpers")
local T = {}

T["setup() loads no content until first open"] = function()
    require("howto").setup({ entries = { { keys = "x", at = "mine", label = "x" } } })
    for name in pairs(package.loaded) do
        assert(not name:match("^howto%.native"), "native content loaded at setup: " .. name)
        assert(name ~= "howto.ui", "UI loaded at setup")
    end
end

T["user entries appear where they are placed and under Mine"] = function()
    require("howto").setup({
        entries = {
            { keys = "<leader>fr", at = "search", label = "project replace", desc = "grug-far across files" },
        },
    })
    h.open()
    h.go("Search")
    h.select("<leader>fr")
    h.contains(h.strip(), "mine")
    h.press("-")
    h.go("Mine")
    h.select("<leader>fr")
end

T["user nodes can rename a native intent"] = function()
    require("howto").setup({ nodes = { { path = "code", label = "LSP" } } })
    h.open()
    h.contains(h.text(), "LSP")
    h.not_contains(h.text(), "Code (LSP)")
end

T["user entry on an unknown path gets an implicit node"] = function()
    require("howto").setup({ entries = { { cmd = ":Dock up", at = "mine/docker", label = "start" } } })
    h.open()
    h.go("Mine", "docker")
    h.select(":Dock up")
end

T["Plugins and Mine are hidden when empty"] = function()
    h.open()
    h.not_contains(h.text(), "Mine")
    -- No pack plugin is installed in the test runtimepath.
    h.not_contains(h.text(), "Plugins")
end

T["a pack shows only when its plugin is installed"] = function()
    local pack = {
        fakepack_a = [[return { plugin = "fake-a.nvim",
            entries = { { keys = "zA", at = "edit", label = "fake a thing" } } }]],
    }
    h.fake_pack_dir(pack)
    h.open()
    h.not_contains(h.text(), "Plugins")
    h.go("Edit")
    h.not_contains(h.text(), "zA")
    h.press("q")

    h.reset()
    h.fake_pack_dir(pack)
    h.fake_plugin("fake-a.nvim")
    h.open()
    h.go("Plugins", "fake-a.nvim")
    h.select("zA")
    h.press("-")
    h.go("Edit")
    h.select("zA")
    h.contains(h.strip(), "fake-a.nvim")
end

T["a pack can name several plugin directories"] = function()
    h.fake_pack_dir({
        fakepack_b = [[return { plugin = { "fake-b.nvim", "fake-bundle.nvim" },
            entries = { { keys = "zB", at = "edit", label = "fake b" } } }]],
    })
    h.fake_plugin("fake-bundle.nvim")
    h.open()
    h.go("Plugins")
    h.contains(h.text(), "fake-b.nvim")
end

T["a broken pack is skipped with a warning, the rest works"] = function()
    h.fake_pack_dir({ fakepack_c = "return { plugin = 'fake-c.nvim', entries = { this is not lua" })
    h.fake_plugin("fake-c.nvim")
    h.open()
    h.contains(h.warnings(), "fakepack_c")
    h.go("Edit", "d  delete", "w  word")
    h.select("diw")
end

T["invalid user entries are skipped with a warning naming the problem"] = function()
    require("howto").setup({
        entries = {
            { at = "edit", label = "no keys, cmd or steps" },
            { keys = "zz1", cmd = ":x", at = "edit", label = "two kinds" },
            { keys = "zz2", label = "no place" },
            { keys = "zz3", at = "edit" },
            { keys = "zz4", at = "edit", label = "fine" },
        },
    })
    h.open()
    local w = h.warnings()
    h.contains(w, "keys, cmd or steps")
    h.contains(w, "at")
    h.contains(w, "label or desc")
    h.go("Edit")
    h.select("zz4")
    h.not_contains(h.text(), "zz1")
    -- Reported once, not on every open.
    local count = #h.notes
    h.press("q")
    require("howto").open()
    assert(#h.notes == count, "warnings repeated on reopen")
end

T["has = feature hides what this Neovim does not support"] = function()
    require("howto").setup({
        entries = {
            { keys = "zH1", at = "edit", label = "future", has = "nvim-99" },
            { keys = "zH2", at = "edit", label = "present", has = "nvim-0.10" },
        },
    })
    h.open()
    h.go("Edit")
    h.select("zH2")
    h.not_contains(h.text(), "zH1")
end

T["checkhealth reports problems"] = function()
    require("howto").setup({ entries = { { at = "edit", label = "broken" } } })
    vim.cmd("checkhealth howto")
    local text = ""
    vim.wait(2000, function()
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[b].filetype == "checkhealth" then
                text = table.concat(vim.api.nvim_buf_get_lines(b, 0, -1, false), "\n")
            end
        end
        return text:find("keys, cmd or steps", 1, true) ~= nil
    end)
    h.contains(text, "keys, cmd or steps")
end

return T
