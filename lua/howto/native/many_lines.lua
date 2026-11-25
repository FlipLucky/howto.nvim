return {
    nodes = {
        { path = "many-lines", label = "Many lines at once", order = 5, desc = "Do the same edit on many lines: block selection, :normal, :g and :v, macros." },
    },
    entries = {
        { steps = { { "<C-v>", "start a block selection" }, { "j j j", "extend down over the lines" }, { "I", "insert before the block" }, { "text", "type it (you only see it on the first line)" }, { "<Esc>", "the text appears on every line" } }, at = "many-lines", label = "insert on many lines", desc = "Adds the same text at the same column on every selected line." },
        { steps = { { "<C-v>", "start a block selection" }, { "j j j", "extend down" }, { "$", "extend every line to its own end" }, { "A", "append after the block" }, { "text<Esc>", "type it; it is added to every line end" } }, at = "many-lines", label = "append to line ends", desc = "Appends text at the end of lines of different lengths (e.g. a ; or ,)." },
        { steps = { { "<C-v>", "start a block selection" }, { "j j l l", "select the columns to replace" }, { "c", "change the block" }, { "text<Esc>", "the new text replaces the block on every line" } }, at = "many-lines", label = "change a column", desc = "Replaces the same columns on every selected line." },
        { cmd = ":'<,'>normal A;", at = "many-lines", label = "run keys on every selected line", desc = "Select lines, press :, then type normal and the keys. They run on each line as if you typed them there.", parts = { { ":'<,'>", "selected lines" }, { "normal", "run Normal-mode keys" }, { " A;", "the keys: append ;" } } },
        { cmd = ":'<,'>normal .", at = "many-lines", label = "repeat last change on each line", desc = "Make a change once, select lines, then repeat that change on each of them.", parts = { { ":'<,'>", "selected lines" }, { "normal", "run keys" }, { " .", "repeat last change" } } },
        { cmd = ":g/pattern/d", at = { "many-lines", "patterns" }, label = "delete lines that match", desc = "Deletes every line that DOES contain pattern (keep-list: :g = where it matches).", parts = { { ":g", "every line matching" }, { "/pattern/", "the pattern" }, { "d", "delete it" } } },
        { cmd = ":v/pattern/d", at = { "many-lines", "patterns" }, label = "delete lines that don't match", desc = "Deletes every line that does NOT contain pattern: only the matching lines stay. Same as :g!.", parts = { { ":v", "every line NOT matching" }, { "/pattern/", "the pattern" }, { "d", "delete it" } } },
        { cmd = ":g/pattern/normal A;", at = { "many-lines", "patterns" }, label = "run keys on matching lines", desc = "Runs Normal-mode keys on every line that matches. Use :v for the lines that don't.", parts = { { ":g/pattern/", "every matching line" }, { "normal", "run keys" }, { " A;", "the keys" } } },
        { cmd = ":g/^$/d", at = { "many-lines", "patterns" }, label = "delete empty lines", desc = "^$ is a line with nothing on it. Use :g/^\\s*$/d to also remove lines with only spaces.", parts = { { ":g", "every line matching" }, { "/^$/", "empty line" }, { "d", "delete" } } },
        { cmd = ":sort", at = "many-lines", label = "sort lines", desc = "Sorts the selected lines (or the whole file). :sort u also removes duplicates, :sort n sorts by number." },
        { keys = "@q", mode = "x", at = { "many-lines", "registers/macros" }, label = "run a macro on each line", desc = "Select lines with V, then @q runs macro q once on every selected line.", has = "nvim-0.11", parts = { { "@", "run macro" }, { "q", "register q" } } },
    },
}
