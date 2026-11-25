-- Undo & repeat, and jumping back to where you were.
return {
    nodes = {
        { path = "undo", label = "Undo & repeat", order = 7, desc = "Take changes back, redo them, repeat them." },
        { path = "jump", label = "Jump back", order = 8, desc = "Go back to where you were: earlier positions, earlier changes, marks." },
        { path = "jump/history", label = "where I was", letter = "^o" },
        { path = "jump/marks", label = "marks (bookmarks)", letter = "m" },
    },
    entries = {
        { keys = "u", at = "undo", label = "undo", desc = "Undoes the last change. A count undoes more: 3u." },
        { keys = "<C-r>", at = "undo", label = "redo", desc = "Redoes what you undid." },
        { keys = "g-", at = "undo", label = "back in time", desc = "Steps back through every state, including undone branches. g+ goes forward." },
        { cmd = ":earlier 5m", at = "undo", label = "as it was 5 minutes ago", desc = "Goes back to the text as it was 5 minutes ago. Also s, h, or f (file writes): :earlier 1f. :later goes forward." },
        { cmd = ":Undotree", at = "undo", label = "visual undo history", desc = "Shows the undo tree; moving in it moves the text. Load it first with :packadd nvim.undotree.", has = "nvim-0.12" },
        { keys = "@:", at = "undo", label = "repeat last :command", desc = "Runs the last command-line command again. @@ repeats it once more." },

        { keys = "<C-o>", at = "jump/history", label = "back to previous position", desc = "Jumps back to where you were before a jump (search, gg, gd, opening a file…). Works across files." },
        { keys = "<C-i>", at = "jump/history", label = "forward again", desc = "Goes forward in the jump list (the same key as <Tab>)." },
        { keys = "g;", at = "jump/history", label = "to the last change", desc = "Jumps to where you last changed something. Repeat to go further back; g, goes forward." },
        { keys = "gi", at = "jump/history", label = "insert where you stopped", desc = "Goes back to where you last left Insert mode, and starts Insert mode there." },
        { keys = "``", at = "jump/history", label = "toggle last two positions", desc = "Jumps back to the position before the latest jump, and back again." },
        { keys = "<C-^>", at = { "jump/history", "buffers" }, label = "previous file", desc = "Switches to the previously used file (the alternate file). Press again to come back." },

        { keys = "m{a}", at = "jump/marks", label = "set a mark", desc = "Remembers the cursor position as mark {a} (a–z in this file).", parts = { { "m", "mark" }, { "{a}", "a letter" } } },
        { keys = "`{a}", at = "jump/marks", label = "jump to a mark", desc = "Jumps to the exact position of mark {a}. '{a} jumps to its line.", parts = { { "`", "go to mark" }, { "{a}", "the letter" } } },
        { keys = "m{A}", at = "jump/marks", label = "mark across files", desc = "A capital letter mark (A–Z) remembers the file too: `A opens the file and jumps there.", parts = { { "m", "mark" }, { "{A}", "a capital letter" } } },
        { cmd = ":marks", at = "jump/marks", label = "list marks", desc = "Lists all marks. :delmarks a deletes one." },
        { keys = "`.", at = "jump/marks", label = "position of last change", desc = "Jumps to where the last change was made.", parts = { { "`", "go to mark" }, { ".", "last change" } } },
        { keys = "`\"", at = "jump/marks", label = "where you were when you left", desc = "Jumps to the position when you last left this file.", parts = { { "`", "go to mark" }, { "\"", "last exit" } } },
    },
}
