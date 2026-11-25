return {
    nodes = {
        { path = "move", label = "Move", order = 1, desc = "Move the cursor. Every motion here also works after a verb: d$, c}, y%." },
        { path = "move/line", label = "within a line", letter = "0$" },
        { path = "move/word", label = "by word", letter = "w" },
        { path = "move/screen", label = "on the screen", letter = "H" },
        { path = "move/file", label = "through the file", letter = "gg" },
        { path = "move/code", label = "through code", letter = "%" },
    },
    entries = {
        { keys = "0", at = "move/line", label = "start of line", desc = "Goes to the very first column." },
        { keys = "^", at = "move/line", label = "first non-blank", desc = "Goes to the first character that isn't a space or tab: where the code starts." },
        { keys = "$", at = "move/line", label = "end of line", desc = "Goes to the last character of the line." },
        { keys = "f{c}", at = "move/line", label = "to a character", desc = "Jumps forward onto the next {c} on this line. F{c} jumps backwards.", parts = { { "f", "find" }, { "{c}", "the character" } } },
        { keys = "t{c}", at = "move/line", label = "just before a character", desc = "Jumps forward to just before the next {c}. T{c} backwards. Great with a verb: dt) deletes up to the ).", parts = { { "t", "till" }, { "{c}", "the character" } } },
        { keys = ";", at = "move/line", label = "repeat f/t", desc = "Repeats the last f, F, t or T. , repeats it in the other direction." },
        { keys = "g_", at = "move/line", label = "last non-blank", desc = "Goes to the last character that isn't whitespace." },
        { keys = "gm", at = "move/line", label = "middle of the screen line", desc = "Goes to the middle of the screen width; gM to the middle of the text." },

        { keys = "w", at = "move/word", label = "next word start", desc = "Jumps to the start of the next word. W skips punctuation (to the next WORD)." },
        { keys = "b", at = "move/word", label = "back to word start", desc = "Jumps back to the start of the word. B for WORD." },
        { keys = "e", at = "move/word", label = "end of word", desc = "Jumps to the end of the word. E for WORD." },
        { keys = "ge", at = "move/word", label = "end of previous word", desc = "Jumps back to the end of the previous word." },
        { keys = "*", at = { "move/word", "search/file" }, label = "next match of this word", desc = "Searches for the word under the cursor, forwards. # searches backwards." },

        { keys = "H", at = "move/screen", label = "top of the screen", desc = "Moves the cursor to the top line on screen. M middle, L bottom." },
        { keys = "<C-d>", at = "move/screen", label = "half a page down", desc = "Scrolls half a screen down. <C-u> scrolls up." },
        { keys = "<C-f>", at = "move/screen", label = "a page down", desc = "Scrolls a full screen down. <C-b> scrolls up." },
        { keys = "zz", at = "move/screen", label = "center this line", desc = "Scrolls so the cursor line is in the middle. zt puts it at the top, zb at the bottom." },
        { keys = "<C-e>", at = "move/screen", label = "scroll one line", desc = "Scrolls the view one line down without moving the cursor. <C-y> up." },
        { keys = "gj", at = "move/screen", label = "down one screen line", desc = "With wrapped lines: moves down one line on screen instead of one line in the file. gk up." },

        { keys = "gg", at = "move/file", label = "top of the file", desc = "Goes to the first line." },
        { keys = "G", at = "move/file", label = "bottom of the file", desc = "Goes to the last line." },
        { keys = "{n}G", at = "move/file", label = "to line {n}", desc = "Goes to line {n}: 42G. Same as :42.", parts = { { "{n}", "line number" }, { "G", "go to line" } } },
        { keys = "}", at = { "move/file", "move/code" }, label = "next blank line", desc = "Jumps to the next blank line: the end of the paragraph or code block. { goes back." },
        { keys = "50%", at = "move/file", label = "to a percentage", desc = "Goes to that percentage of the file: 50% is the middle.", parts = { { "50", "percent" }, { "%", "of the file" } } },

        { keys = "%", at = "move/code", label = "matching bracket", desc = "Jumps between matching ( ), [ ], { }; also #if/#endif and the like." },
        { keys = "[(", at = "move/code", label = "to the enclosing (", desc = "Jumps back to the ( that encloses the cursor. ]) to the closing one. Also [{ and ]}." },
        { keys = "gd", at = "move/code", label = "local definition", desc = "Goes to the local declaration of the word under the cursor (without LSP). With an LSP, prefer <C-]>." },
        { keys = "]d", at = { "move/code", "code/diagnostics" }, label = "next diagnostic", desc = "Jumps to the next error or warning. [d goes back, ]D / [D to the last / first.", has = "nvim-0.10" },
    },
}
