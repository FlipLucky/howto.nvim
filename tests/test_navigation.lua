-- The user's way through the tree: intents first, deeper with l, back with h.
local h = require("helpers")
local T = {}

T["opens on the list of intents"] = function()
    h.open()
    local text = h.text()
    for _, intent in ipairs({ "Move", "Edit", "Select", "Search", "Many lines at once", "Patterns (regex)" }) do
        h.contains(text, intent)
    end
    assert(vim.startswith(h.selected(), "Move"), "first intent should be selected, got " .. tostring(h.selected()))
    h.contains(h.title(), "Howto")
end

T["walks verb, noun, modifier down to diw"] = function()
    h.open()
    h.go("Edit", "d  delete", "w  word")
    local text = h.text()
    for _, key in ipairs({ "dw", "de", "db", "diw", "daw" }) do
        h.contains(text, key)
    end
    h.select("diw")
    local strip = h.strip()
    h.contains(strip, "d=delete")
    h.contains(strip, "i=inner")
    h.contains(strip, "w=word")
    h.contains(strip, "ciw", "strip should point at the same object with other verbs")
    h.contains(h.title(), "Edit › delete › word")
end

T["shows the path as columns and goes back with h"] = function()
    h.open()
    h.go("Edit", "d  delete", "w  word")
    -- The parent levels stay visible next to the keys.
    h.contains(h.text(), "delete")
    h.contains(h.text(), "change")
    h.press("h")
    assert(vim.startswith(h.selected(), "w  word"), "back should land on the node we came from, got " .. tostring(h.selected()))
    h.contains(h.title(), "Edit › delete")
    h.not_contains(h.title(), "› word")
end

T["minus jumps straight back to the intents"] = function()
    h.open()
    h.go("Edit", "d  delete", "w  word")
    h.press("-")
    assert(vim.startswith(h.selected(), "Edit"), "should be on the intent we were in, got " .. tostring(h.selected()))
    h.not_contains(h.title(), "›")
end

T["moving the cursor previews the selected node in the next column"] = function()
    h.open()
    h.select("Edit")
    h.contains(h.text(), "delete", "children of Edit should be previewed before entering it")
end

T["l on an entry does nothing and keeps the strip"] = function()
    h.open()
    h.go("Edit", "d  delete", "w  word")
    h.select("diw")
    h.press("l")
    assert(vim.startswith(h.selected(), "diw"))
end

T["a recipe shows numbered steps in the strip"] = function()
    h.open()
    h.go("Many lines at once")
    h.select("insert on many lines")
    local strip = h.strip()
    h.contains(strip, "1.")
    h.contains(strip, "<C-v>")
    h.contains(strip, "<Esc>")
end

T["one entry is found in several places"] = function()
    h.open()
    h.go("Many lines at once")
    h.select(":g/pattern/d")
    h.press("-")
    h.go("Patterns (regex)")
    h.select(":g/pattern/d")
end

T["k at the top and j at the bottom stay inside the list"] = function()
    h.open()
    h.press("k")
    assert(vim.startswith(h.selected(), "Move"))
    h.press("G")
    for _ = 1, 50 do h.press("j") end
    assert(h.selected(), "something stays selected at the bottom")
end

T[":Howto with a path opens at that place"] = function()
    vim.cmd("runtime plugin/howto.lua")
    vim.cmd("Howto edit/delete/word")
    assert(h.win(), "window should open")
    h.contains(h.title(), "Edit › delete › word")
end

return T
