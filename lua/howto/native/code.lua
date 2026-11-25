-- LSP, diagnostics, quickfix lists, folds.
return {
    nodes = {
        { path = "code", label = "Code (LSP)", order = 11, desc = "Understand and change code with a language server. Neovim's own defaults." },
        { path = "code/navigate", label = "go to", letter = "^]" },
        { path = "code/refactor", label = "rename & fix", letter = "grn" },
        { path = "code/info", label = "info", letter = "K" },
        { path = "code/diagnostics", label = "errors & warnings", letter = "]d" },
        { path = "lists", label = "Lists (quickfix)", order = 12, desc = "Lists of places: search results, errors, references. Walk through them one by one." },
        { path = "folds", label = "Folds", order = 13, desc = "Hide and show blocks of lines. Needs a 'foldmethod' (e.g. indent or expr with treesitter)." },
    },
    entries = {
        { keys = "<C-]>", at = "code/navigate", label = "go to definition", desc = "Jumps to the definition (uses the LSP when attached). <C-o> brings you back." },
        { keys = "grr", at = "code/navigate", label = "references", desc = "Lists every place the symbol is used, in the quickfix list.", has = "nvim-0.11" },
        { keys = "gri", at = "code/navigate", label = "implementation", desc = "Goes to the implementation(s) of an interface or method.", has = "nvim-0.11" },
        { keys = "grt", at = "code/navigate", label = "type definition", desc = "Goes to the definition of the symbol's type.", has = "nvim-0.12" },
        { keys = "gO", at = "code/navigate", label = "outline of this file", desc = "Lists the symbols in this file (functions, classes…) to jump to.", has = "nvim-0.11" },

        { keys = "grn", at = { "code/refactor", "search/replace" }, label = "rename symbol", desc = "Renames the symbol everywhere it is used, through the LSP. For plain text, use :s instead.", has = "nvim-0.11" },
        { keys = "gra", at = "code/refactor", label = "code action", desc = "Shows fixes and refactors for the cursor or selection (import, extract, quick fix…).", has = "nvim-0.11" },
        { keys = "gq", mode = "x", at = "code/refactor", label = "format selection", desc = "Formats the selected lines through the LSP when it provides formatting." },

        { keys = "K", at = "code/info", label = "hover documentation", desc = "Shows the documentation of the symbol under the cursor. Press K again to enter the popup." },
        { keys = "<C-s>", mode = "i", at = { "code/info", "insert" }, label = "signature help", desc = "In Insert mode: shows the parameters of the function you're calling.", has = "nvim-0.11" },
        { keys = "gx", at = "code/info", label = "open link / docs", desc = "Opens the URL or path under the cursor in the system app (or LSP document links)." },

        { keys = "<C-w>d", at = "code/diagnostics", label = "show the message", desc = "Opens the full error or warning message under the cursor in a float.", has = "nvim-0.10" },
        { keys = "[d", at = "code/diagnostics", label = "previous diagnostic", desc = "Jumps to the previous error or warning. ]d the next.", has = "nvim-0.10" },
        { cmd = ":lua vim.diagnostic.setqflist()", at = { "code/diagnostics", "lists" }, label = "all diagnostics in a list", desc = "Puts every diagnostic in the quickfix list, to walk through with ]q." },

        { cmd = ":copen", at = "lists", label = "open the quickfix list", desc = "Shows the list. <CR> on a line jumps there. :cclose closes it." },
        { keys = "]q", at = "lists", label = "next item", desc = "Goes to the next quickfix item. [q the previous, [Q / ]Q first / last.", has = "nvim-0.11" },
        { keys = "]l", at = "lists", label = "next location-list item", desc = "The location list is a per-window quickfix list. [l the previous, :lopen to show it.", has = "nvim-0.11" },
        { cmd = ":cdo {cmd}", at = "lists", label = "run a command on every item", desc = "Runs {cmd} on every line in the list: :cdo s/a/b/ | update." },
        { cmd = ":colder", at = "lists", label = "previous list", desc = "Goes back to the previous quickfix list (Vim keeps the last 10). :cnewer forward." },
        { cmd = ":cfilter /pattern/", at = "lists", label = "filter the list", desc = "Keeps only items matching pattern (:cfilter! removes them). Load with :packadd cfilter." },

        { keys = "za", at = "folds", label = "toggle a fold", desc = "Opens or closes the fold under the cursor." },
        { keys = "zR", at = "folds", label = "open all folds", desc = "Opens every fold in the file. zM closes all." },
        { keys = "zc", at = "folds", label = "close a fold", desc = "Closes the fold. zo opens it." },
        { keys = "zj", at = "folds", label = "to the next fold", desc = "Moves to the start of the next fold. zk to the end of the previous one." },
        { keys = "zfip", at = "folds", label = "create a fold", desc = "Creates a fold over the paragraph (with foldmethod=manual). zd deletes it.", parts = { { "zf", "fold" }, { "i", "inner" }, { "p", "paragraph" } } },
    },
}
