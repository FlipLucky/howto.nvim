-- Registers, macros and Insert mode.
return {
    nodes = {
        { path = "registers", label = "Registers & macros", order = 14, desc = "Registers are named clipboards; a macro is a register you play back as keys." },
        { path = "registers/use", label = "registers", letter = "\"" },
        { path = "registers/macros", label = "macros", letter = "q" },
        { path = "insert", label = "Insert mode", order = 15, desc = "What you can do without leaving Insert mode." },
    },
    entries = {
        { keys = "\"ayiw", at = "registers/use", label = "copy into register a", desc = "Prefix any yank, delete or paste with \"{r} to use register {r}. \"ap pastes it.", parts = { { "\"a", "register a" }, { "y", "yank" }, { "i", "inner" }, { "w", "word" } } },
        { keys = "\"+y", mode = "x", at = "registers/use", label = "copy to the system clipboard", desc = "Copies the selection to the system clipboard. Or set clipboard=unnamedplus to always use it." },
        { keys = "\"_d", at = "registers/use", label = "delete without copying", desc = "The black hole register: deletes without overwriting what you copied. \"_diw, \"_dd…", parts = { { "\"_", "black hole" }, { "d", "delete" } } },
        { cmd = ":reg", at = "registers/use", label = "show registers", desc = "Lists the contents of all registers." },
        { keys = "<C-r>{r}", mode = "i", at = { "registers/use", "insert" }, label = "insert a register", desc = "In Insert mode or on the : command line: inserts register {r}. <C-r>\" the last delete/yank, <C-r>+ the clipboard.", parts = { { "<C-r>", "insert register" }, { "{r}", "which one" } } },

        { keys = "qq", at = "registers/macros", label = "record a macro", desc = "Starts recording your keys into register q. Press q again to stop.", parts = { { "q", "record" }, { "q", "into register q" } } },
        { keys = "@q", at = "registers/macros", label = "play the macro", desc = "Plays macro q. 10@q plays it 10 times; it stops at the first failing motion.", parts = { { "@", "play" }, { "q", "register q" } } },
        { keys = "@@", at = "registers/macros", label = "play the last macro again", desc = "Repeats the last played macro." },
        { cmd = ":'<,'>normal @q", at = { "registers/macros", "many-lines" }, label = "macro on every selected line", desc = "Runs macro q once on each selected line.", parts = { { ":'<,'>", "selected lines" }, { "normal", "run keys" }, { " @q", "play macro q" } } },

        { keys = "<C-w>", mode = "i", at = "insert", label = "delete word before", desc = "Deletes the word before the cursor." },
        { keys = "<C-u>", mode = "i", at = "insert", label = "delete to line start", desc = "Deletes everything before the cursor on this line." },
        { keys = "<C-o>", mode = "i", at = "insert", label = "one Normal command", desc = "Runs one Normal-mode command and returns to Insert mode: <C-o>zz, <C-o>dd." },
        { keys = "<C-t>", mode = "i", at = "insert", label = "indent the line", desc = "Indents the current line. <C-d> dedents." },
        { keys = "<C-n>", mode = "i", at = "insert", label = "complete a word", desc = "Completes with words from open buffers. <C-p> searches backwards." },
        { keys = "<C-x><C-f>", mode = "i", at = "insert", label = "complete a file path", desc = "Completes file names. <C-x><C-l> completes whole lines.", parts = { { "<C-x>", "completion mode" }, { "<C-f>", "files" } } },
        { keys = "<C-a>", mode = "i", at = "insert", label = "insert last inserted text", desc = "Types again what you typed the last time you were in Insert mode." },
        { keys = "<C-r>=", mode = "i", at = "insert", label = "insert a calculation", desc = "Evaluates an expression and inserts the result: <C-r>=6*7<CR> inserts 42.", parts = { { "<C-r>", "insert register" }, { "=", "expression" } } },
        { keys = "<C-v>{c}", mode = "i", at = "insert", label = "insert literally", desc = "Inserts the next key as-is: <C-v><Tab> inserts a real tab even with expandtab.", parts = { { "<C-v>", "literal" }, { "{c}", "the key" } } },
        { keys = "<C-k>{ab}", mode = "i", at = "insert", label = "special character", desc = "Inserts a digraph: <C-k>e: gives ë, <C-k>Eu gives €. :digraphs lists them.", parts = { { "<C-k>", "digraph" }, { "{ab}", "two letters" } } },
    },
}
