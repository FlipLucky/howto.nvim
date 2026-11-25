-- oil.nvim: edit a directory like a buffer. Default keymaps from oil's config.
return {
    plugin = "oil.nvim",
    nodes = {
        { path = "files", label = "Files (oil)", order = 9.5, desc = "Browse and change files as text: rename by editing a line, delete with dd, then :w." },
    },
    entries = {
        { cmd = ":Oil", at = "files", label = "open the directory", desc = "Opens the directory of the current file as an editable buffer." },
        { keys = "-", at = "files", label = "parent directory", desc = "In an oil buffer: goes one directory up." },
        { keys = "<CR>", at = "files", label = "open file or directory", desc = "<C-s> opens in a vertical split, <C-h> in a horizontal split, <C-t> in a tab." },
        { steps = { { "cw", "edit the name on the line" }, { "dd", "or delete a line to delete that file" }, { "o new.txt", "or add a line to create a file (end with / for a directory)" }, { ":w", "apply: oil shows what it will do and asks to confirm" } }, at = "files", label = "rename, delete, create", desc = "File operations are text edits; nothing happens until you write the buffer." },
        { keys = "g.", at = "files", label = "show hidden files", desc = "Toggles dotfiles." },
        { keys = "<C-p>", at = "files", label = "preview", desc = "Previews the file under the cursor." },
        { keys = "g?", at = "files", label = "all oil keys", desc = "Shows oil's help with every key." },
    },
}
