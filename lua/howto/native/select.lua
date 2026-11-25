local g = require("howto.grammar")

local nodes = {
    { path = "select", label = "Select", order = 3, desc = "Visual mode: select first, then act (d, c, y, >, gc, :…)." },
    { path = "select/start", label = "start selecting", letter = "v" },
    { path = "select/object", label = "select an object", letter = "i/a", desc = "v + the same objects as delete and change: viw, vi\", vap…" },
    { path = "select/grow", label = "grow / shrink by code", letter = "an", desc = "Select by syntax node: argument → call → statement → function." },
    { path = "select/adjust", label = "adjust a selection", letter = "o" },
}

local n, e = g.for_verb("v", "select/object")
vim.list_extend(nodes, n)
local entries = e

vim.list_extend(entries, {
    { keys = "v", at = "select/start", label = "by character", desc = "Starts selecting characters. Move to extend; then d, c, y, > or : on it." },
    { keys = "V", at = { "select/start", "many-lines" }, label = "by line", desc = "Selects whole lines. Move up/down to add lines." },
    { keys = "<C-v>", at = { "select/start", "many-lines" }, label = "a block (columns)", desc = "Selects a rectangle. Use it to edit the same column on many lines (I, A, c, $A)." },
    { keys = "gv", at = { "select/start", "select/adjust" }, label = "reselect last selection", desc = "Selects the previous selection again: after > or a :command you can continue on the same lines." },
    { keys = "ggVG", at = "select/start", label = "select everything", desc = "Goes to the top, selects by line, goes to the bottom.", parts = { { "gg", "top" }, { "V", "select lines" }, { "G", "bottom" } } },
    { keys = "al", mode = "x", at = "select/start", label = "whole buffer", desc = "In Visual mode: selects all lines. il selects the current line without its surrounding whitespace.", has = "nvim-0.13" },

    { keys = "an", mode = "x", at = "select/grow", label = "grow to parent node", desc = "Grows the selection to the enclosing syntax node; repeat to keep growing. Uses treesitter, or the LSP when there's no parser.", has = "nvim-0.12" },
    { keys = "in", mode = "x", at = "select/grow", label = "shrink to child node", desc = "Shrinks the selection back to an inner node.", has = "nvim-0.12" },
    { keys = "]n", mode = "x", at = "select/grow", label = "next sibling node", desc = "Moves the selection to the next node at the same level (e.g. next argument).", has = "nvim-0.12" },
    { keys = "[n", mode = "x", at = "select/grow", label = "previous sibling node", desc = "Moves the selection to the previous node at the same level.", has = "nvim-0.12" },

    { keys = "o", mode = "x", at = "select/adjust", label = "jump to the other end", desc = "Moves the cursor to the other end of the selection, so you can extend it the other way." },
    { keys = "O", mode = "x", at = "select/adjust", label = "other corner (block)", desc = "In a block selection: moves to the other corner on the same line." },
    { keys = "$", mode = "x", at = "select/adjust", label = "block to line ends", desc = "In a block selection: extends every line to its own end, even when lines have different lengths." },
})

return { nodes = nodes, entries = entries }
