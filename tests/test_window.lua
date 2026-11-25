-- Window behaviour: closing, reopening, leaving, small screens, search.
local h = require("helpers")
local T = {}

T["q closes and the user is back where they were"] = function()
    local before = vim.api.nvim_get_current_win()
    h.open()
    h.press("q")
    assert(not h.win(), "window should be closed")
    assert(vim.api.nvim_get_current_win() == before, "focus should return to the original window")
end

T["Esc closes"] = function()
    h.open()
    h.press("<Esc>")
    assert(not h.win())
end

T["opening twice gives one window"] = function()
    h.open()
    require("howto").open()
    local n = 0
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "howto" then
            n = n + 1
        end
    end
    assert(n == 1, "expected one howto window, got " .. n)
end

T["reopening after close works and starts at the intents"] = function()
    h.open()
    h.go("Edit")
    h.press("q")
    h.open()
    assert(vim.startswith(h.selected(), "Move"))
end

T["leaving the window closes it"] = function()
    h.open()
    vim.cmd("wincmd p")
    assert(not h.win(), "window should close when focus leaves it")
end

T["narrow screen: nothing overflows the window"] = function()
    vim.o.columns, vim.o.lines = 50, 16
    h.open()
    h.go("Edit", "d  delete", "w  word")
    local width = vim.api.nvim_win_get_width(h.win())
    for _, l in ipairs(h.lines()) do
        assert(vim.fn.strdisplaywidth(l) <= width, ("line wider than window (%d > %d): %s"):format(vim.fn.strdisplaywidth(l), width, l))
    end
    assert(h.selected(), "an item is still selected")
end

T["resizing the editor keeps the place in the tree"] = function()
    h.open()
    h.go("Edit", "d  delete")
    vim.o.columns = 90
    vim.api.nvim_exec_autocmds("VimResized", {})
    assert(h.win(), "still open")
    h.contains(h.title(), "Edit › delete")
end

T["search lists matching entries from everywhere"] = function()
    h.open()
    local orig = vim.ui.input
    vim.ui.input = function(_, cb) cb("whole word") end
    h.press("/")
    vim.ui.input = orig
    h.contains(h.title(), "whole word")
    h.contains(h.text(), "diw")
    h.contains(h.text(), "ciw")
    h.press("h")
    assert(vim.startswith(h.selected(), "Move"), "back from search returns to the intents")
end

T["search works when vim.ui.input opens its own window (snacks, dressing)"] = function()
    h.open()
    local orig = vim.ui.input
    local pending
    vim.ui.input = function(_, cb)
        -- Like a floating input plugin: focus moves to a new window, the answer comes later.
        local buf = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(buf, true, { relative = "editor", row = 1, col = 1, width = 20, height = 1 })
        pending = function(answer)
            vim.api.nvim_win_close(win, true)
            cb(answer)
        end
    end
    h.press("/")
    vim.ui.input = orig
    assert(pending, "input was not asked")
    pending("whole word")
    assert(h.win(), "howto closed while the input window was open")
    h.contains(h.title(), "whole word")
    assert(vim.api.nvim_get_current_win() == h.win(), "focus should be back in howto")
end

T["cancelling a floating input returns to howto"] = function()
    h.open()
    local orig = vim.ui.input
    vim.ui.input = function(_, cb)
        local buf = vim.api.nvim_create_buf(false, true)
        local win = vim.api.nvim_open_win(buf, true, { relative = "editor", row = 1, col = 1, width = 20, height = 1 })
        vim.api.nvim_win_close(win, true)
        cb(nil)
    end
    h.press("/")
    vim.ui.input = orig
    assert(h.win(), "howto should still be open")
    assert(vim.api.nvim_get_current_win() == h.win(), "focus should be back in howto")
end

T["search without results says so"] = function()
    h.open()
    local orig = vim.ui.input
    vim.ui.input = function(_, cb) cb("zzqqxx-nothing") end
    h.press("/")
    vim.ui.input = orig
    h.contains(h.text(), "No matches")
end

T["cancelled search changes nothing"] = function()
    h.open()
    local orig = vim.ui.input
    vim.ui.input = function(_, cb) cb(nil) end
    h.press("/")
    vim.ui.input = orig
    assert(vim.startswith(h.selected(), "Move"))
end

return T
