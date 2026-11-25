return {
    nodes = {
        { path = "search", label = "Search", order = 4, desc = "Find text in this file or across files, and replace it." },
        { path = "search/file", label = "in this file", letter = "/" },
        { path = "search/replace", label = "replace", letter = ":s" },
        { path = "search/files", label = "across files", letter = ":vim" },
    },
    entries = {
        { keys = "/{text}<CR>", at = "search/file", label = "search forward", desc = "Searches forward for {text} (a pattern). ?{text} searches backwards.", parts = { { "/", "search" }, { "{text}", "what to find" }, { "<CR>", "go" } } },
        { keys = "n", at = "search/file", label = "next match", desc = "Goes to the next match of the last search. N goes to the previous one." },
        { keys = "#", at = "search/file", label = "previous match of this word", desc = "Searches backwards for the word under the cursor. * searches forwards." },
        { keys = "*", mode = "x", at = "search/file", label = "search the selection", desc = "In Visual mode: searches for the selected text.", has = "nvim-0.10" },
        { keys = "<C-l>", at = "search/file", label = "clear the highlight", desc = "Clears search highlighting (Neovim default) and redraws the screen. Or :nohlsearch." },
        { keys = "/\\c{text}<CR>", at = { "search/file", "patterns" }, label = "ignore case once", desc = "\\c anywhere in a pattern makes this one search case-insensitive; \\C makes it case-sensitive.", parts = { { "/", "search" }, { "\\c", "ignore case" }, { "{text}", "what to find" }, { "<CR>", "go" } } },

        { cmd = ":s/old/new/", at = "search/replace", label = "first on this line", desc = "Replaces the first old on the current line.", parts = { { ":s", "substitute" }, { "/old", "find" }, { "/new/", "replace with" } } },
        { cmd = ":%s/old/new/g", at = { "search/replace", "patterns" }, label = "everywhere in the file", desc = "Replaces every old in the whole file.", parts = { { ":%", "all lines" }, { "s", "substitute" }, { "/old/new/", "find / replace" }, { "g", "every match on a line" } } },
        { cmd = ":%s/old/new/gc", at = "search/replace", label = "everywhere, ask each time", desc = "Like :%s///g but asks y/n for each match: y yes, n no, a all, q quit.", parts = { { ":%s/old/new/", "substitute" }, { "g", "every match" }, { "c", "confirm each" } } },
        { cmd = ":'<,'>s/old/new/g", at = { "search/replace", "many-lines" }, label = "in the selection", desc = "Select lines first, then press : — Vim fills in '<,'> (the selection) for you.", parts = { { ":'<,'>", "selected lines" }, { "s/old/new/", "substitute" }, { "g", "every match" } } },
        { cmd = ":%s//new/g", at = { "search/replace", "patterns" }, label = "replace what you last searched", desc = "An empty pattern reuses the last search: search with / or * first, check the matches, then replace.", parts = { { ":%s", "substitute, all lines" }, { "//", "last search" }, { "new/g", "replace, every match" } } },
        { steps = { { "*", "search the word under the cursor (or /text<CR>)" }, { "cgn", "change the next match" }, { "new text<Esc>", "type the replacement" }, { ".", "repeat on the next match (n to skip one)" } }, at = { "search/replace", "edit/change" }, label = "replace one by one with .", desc = "Replace matches one at a time, choosing each: . changes the next match, n skips it." },
        { keys = "&", at = "search/replace", label = "repeat last :s on this line", desc = "Repeats the last substitute on the current line. g& repeats it on all lines." },

        { cmd = ":vimgrep /text/ **/*.lua", at = "search/files", label = "search files into quickfix", desc = "Searches all matching files and puts the results in the quickfix list (:copen to see them, ]q for the next).", parts = { { ":vimgrep", "search files" }, { "/text/", "pattern" }, { "**/*.lua", "which files" } } },
        { cmd = ":grep text", at = "search/files", label = "external grep into quickfix", desc = "Runs 'grepprg' (ripgrep when installed) and fills the quickfix list. Faster than :vimgrep on big projects." },
        { steps = { { ":grep old", "find every file with old (fills quickfix)" }, { ":cdo s/old/new/g", "replace on every quickfix line" }, { ":wa", "write all changed files" } }, at = { "search/files", "search/replace", "lists" }, label = "replace across files", desc = "Search first, check the list, then replace only there. :cfdo %s/old/new/g works per file instead of per line." },
    },
}
