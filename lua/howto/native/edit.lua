local g = require("howto.grammar")

local nodes = {
    { path = "edit", label = "Edit", order = 2, desc = "Change text: verb first (delete, change, yank…), then what (word, quotes, line…)." },
    { path = "edit/delete", label = "delete", letter = "d", desc = "d + what to delete. Deleted text goes into a register, so you can paste it." },
    { path = "edit/change", label = "change", letter = "c", desc = "c + what to change: deletes it and starts Insert mode." },
    { path = "edit/yank", label = "yank (copy)", letter = "y", desc = "y + what to copy. Paste with p." },
    { path = "edit/paste", label = "paste", letter = "p" },
    { path = "edit/small", label = "small edits", letter = "x", desc = "One character, swaps, joins: no verb + object needed." },
    { path = "edit/indent", label = "indent", letter = ">" },
    { path = "edit/case", label = "upper/lower case", letter = "~" },
    { path = "edit/comment", label = "comment", letter = "gc" },
    { path = "edit/numbers", label = "numbers", letter = "^a" },
    { path = "edit/format", label = "format & wrap", letter = "gq" },
}
local entries = {}

for verb, base in pairs({ d = "edit/delete", c = "edit/change", y = "edit/yank" }) do
    local n, e = g.for_verb(verb, base)
    vim.list_extend(nodes, n)
    vim.list_extend(entries, e)
end

vim.list_extend(entries, {
    -- paste
    { keys = "p", at = "edit/paste", label = "after the cursor", desc = "Pastes after the cursor, or below the line when you copied whole lines." },
    { keys = "P", at = "edit/paste", label = "before the cursor", desc = "Pastes before the cursor, or above the line for whole lines." },
    { keys = "\"0p", at = { "edit/paste", "registers/use" }, label = "last yank, not last delete", desc = "Register 0 holds the last yank. Deleting text doesn't overwrite it, so this pastes what you copied even after a dd.", parts = { { "\"0", "register 0 (last yank)" }, { "p", "paste" } } },
    { keys = "\"+p", at = { "edit/paste", "registers/use" }, label = "from the system clipboard", desc = "Pastes from the system clipboard (needs a clipboard tool such as wl-clipboard or xclip).", parts = { { "\"+", "clipboard register" }, { "p", "paste" } } },
    { keys = "gp", at = "edit/paste", label = "paste, cursor after it", desc = "Like p, but leaves the cursor after the pasted text: handy to paste several times in a row." },
    { keys = "]<Space>", at = "edit/paste", label = "empty line below", desc = "Adds an empty line below without entering Insert mode. [<Space> adds one above.", has = "nvim-0.11" },
    { keys = "p", mode = "x", at = "edit/paste", label = "replace selection", desc = "In Visual mode p replaces the selection with what you copied. The replaced text goes into the register; use P to keep the register." },

    -- small edits
    { keys = "x", at = "edit/small", label = "delete character", desc = "Deletes the character under the cursor. X deletes the one before it." },
    { keys = "r{c}", at = "edit/small", label = "replace one character", desc = "Replaces the character under the cursor with {c} and stays in Normal mode.", parts = { { "r", "replace" }, { "{c}", "new character" } } },
    { keys = "R", at = "edit/small", label = "overwrite (Replace mode)", desc = "Typing overwrites existing text until <Esc>." },
    { keys = "xp", at = "edit/small", label = "swap two characters", desc = "Deletes the character and pastes it after the next: teh → the.", parts = { { "x", "delete char" }, { "p", "paste after" } } },
    { keys = "ddp", at = "edit/small", label = "swap two lines", desc = "Moves the current line down one.", parts = { { "dd", "delete line" }, { "p", "paste below" } } },
    { keys = "J", at = "edit/small", label = "join lines", desc = "Joins the line below onto this one with a space. gJ joins without a space." },
    { keys = "s", at = "edit/small", label = "change one character", desc = "Deletes the character under the cursor and starts Insert mode. S changes the whole line." },
    { keys = ".", at = { "edit/small", "undo" }, label = "repeat last change", desc = "Repeats the last change at the cursor. The most useful key in Vim: make a change once, then . elsewhere." },

    -- indent
    { keys = ">>", at = "edit/indent", label = "indent line", desc = "Indents the line one 'shiftwidth'. << dedents. A count does more lines: 3>>." },
    { keys = ">ip", at = "edit/indent", label = "indent paragraph", desc = "Indents the whole block of lines. Works with any object: >i{ indents inside braces.", parts = { { ">", "indent" }, { "i", "inner" }, { "p", "paragraph" } } },
    { keys = ">", mode = "x", at = "edit/indent", label = "indent selection", desc = "Indents the selected lines. Use . to indent again, or gv to reselect." },
    { keys = "==", at = { "edit/indent", "edit/format" }, label = "re-indent line", desc = "Fixes the indent of the line using the filetype's rules." },
    { keys = "=ip", at = { "edit/indent", "edit/format" }, label = "re-indent paragraph", desc = "Fixes the indent of the block. gg=G re-indents the whole file.", parts = { { "=", "re-indent" }, { "i", "inner" }, { "p", "paragraph" } } },

    -- case
    { keys = "~", at = "edit/case", label = "toggle one character", desc = "Toggles the case of the character under the cursor and moves right." },
    { keys = "guiw", at = "edit/case", label = "word to lowercase", desc = "Any object works: gu + motion.", parts = { { "gu", "lowercase" }, { "i", "inner" }, { "w", "word" } } },
    { keys = "gUiw", at = "edit/case", label = "word to UPPERCASE", desc = "Any object works: gU + motion.", parts = { { "gU", "uppercase" }, { "i", "inner" }, { "w", "word" } } },
    { keys = "g~iw", at = "edit/case", label = "toggle a word", desc = "Toggles the case of every letter in the word.", parts = { { "g~", "toggle case" }, { "i", "inner" }, { "w", "word" } } },
    { keys = "U", mode = "x", at = "edit/case", label = "selection to UPPERCASE", desc = "In Visual mode: U uppercase, u lowercase, ~ toggle." },

    -- comment
    { keys = "gcc", at = "edit/comment", label = "comment line", desc = "Comments or uncomments the line. A count does more: 3gcc.", parts = { { "gc", "comment" }, { "c", "line (twice)" } }, has = "nvim-0.10" },
    { keys = "gcip", at = { "edit/comment", "many-lines" }, label = "comment paragraph", desc = "Comments the whole block of lines. gc works with any motion or object.", parts = { { "gc", "comment" }, { "i", "inner" }, { "p", "paragraph" } }, has = "nvim-0.10" },
    { keys = "gc", mode = "x", at = "edit/comment", label = "comment selection", desc = "Comments or uncomments the selected lines.", has = "nvim-0.10" },

    -- numbers
    { keys = "<C-a>", at = "edit/numbers", label = "increment number", desc = "Adds 1 to the number under or after the cursor. 5<C-a> adds 5. <C-x> subtracts." },
    { keys = "g<C-a>", mode = "x", at = { "edit/numbers", "many-lines" }, label = "make a sequence", desc = "On a selection of lines that all say 0: turns them into 1, 2, 3, …", parts = { { "g", "progressive" }, { "<C-a>", "increment" } } },

    -- format
    { keys = "gqip", at = "edit/format", label = "wrap paragraph", desc = "Re-wraps the paragraph to 'textwidth' (or formats with the LSP / formatter when 'formatexpr' is set).", parts = { { "gq", "format" }, { "i", "inner" }, { "p", "paragraph" } } },
    { keys = "gwip", at = "edit/format", label = "wrap, keep cursor", desc = "Like gq, but the cursor stays where it was.", parts = { { "gw", "format, keep cursor" }, { "i", "inner" }, { "p", "paragraph" } } },
})

return { nodes = nodes, entries = entries }
