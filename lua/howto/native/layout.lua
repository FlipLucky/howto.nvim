-- Buffers, windows, tabs.
return {
    nodes = {
        { path = "buffers", label = "Buffers", order = 9, desc = "Open files. A buffer stays open (hidden) when you switch away from it." },
        { path = "windows", label = "Windows", order = 10, desc = "Split the screen, move between and around windows, tabs." },
        { path = "windows/split", label = "split", letter = "^ws" },
        { path = "windows/go", label = "go to a window", letter = "^wh" },
        { path = "windows/size", label = "resize", letter = "^w=" },
        { path = "windows/arrange", label = "move & close", letter = "^wH" },
        { path = "windows/tabs", label = "tabs", letter = "gt" },
    },
    entries = {
        { cmd = ":ls", at = "buffers", label = "list open buffers", desc = "Shows every open buffer with its number. % is the current one, # the previous." },
        { cmd = ":b {name}", at = "buffers", label = "switch by name", desc = "Switches to a buffer by part of its name; <Tab> completes. :b 3 by number." },
        { keys = "]b", at = "buffers", label = "next buffer", desc = "Goes to the next buffer in the list. [b the previous, [B / ]B the first / last.", has = "nvim-0.11" },
        { cmd = ":e {file}", at = "buffers", label = "open a file", desc = "Opens a file in this window; <Tab> completes paths. :e! reloads the file and throws away changes." },
        { keys = "gf", at = "buffers", label = "open the file under the cursor", desc = "Opens the path under the cursor. <C-w>f opens it in a split." },
        { cmd = ":bd", at = "buffers", label = "close the buffer", desc = "Removes the buffer from the list (asks when it has unsaved changes). The window closes too unless it's the last." },
        { cmd = ":wa", at = "buffers", label = "write all", desc = "Writes every changed buffer. :wqa writes all and quits." },

        { keys = "<C-w>s", at = "windows/split", label = "split horizontally", desc = "Splits the window: the same buffer above and below. :split {file} opens a file there." },
        { keys = "<C-w>v", at = "windows/split", label = "split vertically", desc = "Splits side by side. :vsplit {file} opens a file there." },
        { keys = "<C-w>n", at = "windows/split", label = "new empty window", desc = "Splits with a new, empty buffer." },
        { keys = "<C-w>T", at = { "windows/split", "windows/tabs" }, label = "move window to a new tab", desc = "Takes the current window out and opens it as its own tab." },

        { keys = "<C-w>h", at = "windows/go", label = "window to the left", desc = "<C-w>j below, <C-w>k above, <C-w>l right." },
        { keys = "<C-w>w", at = "windows/go", label = "next window", desc = "Cycles through windows." },
        { keys = "<C-w>p", at = "windows/go", label = "previous window", desc = "Goes back to the window you were in before." },

        { keys = "<C-w>=", at = "windows/size", label = "make all equal", desc = "Gives all windows the same size." },
        { keys = "<C-w>_", at = "windows/size", label = "maximise height", desc = "Makes this window as tall as possible. <C-w>| as wide as possible; <C-w>= to undo." },
        { keys = "<C-w>+", at = "windows/size", label = "taller / shorter", desc = "One line taller; <C-w>- shorter. 10<C-w>+ for ten lines." },
        { keys = "<C-w>>", at = "windows/size", label = "wider / narrower", desc = "One column wider; <C-w>< narrower." },

        { keys = "<C-w>H", at = "windows/arrange", label = "move to the far left", desc = "Moves the window to the far left, full height. J bottom, K top, L right." },
        { keys = "<C-w>x", at = "windows/arrange", label = "swap with the next", desc = "Swaps this window with the next one." },
        { keys = "<C-w>c", at = "windows/arrange", label = "close this window", desc = "Closes the window (the buffer stays open). :q does the same." },
        { keys = "<C-w>o", at = "windows/arrange", label = "close all others", desc = "Keeps only this window." },

        { cmd = ":tabnew", at = "windows/tabs", label = "new tab", desc = "Opens a new tab page. :tabnew {file} opens a file in it." },
        { keys = "gt", at = "windows/tabs", label = "next tab", desc = "Goes to the next tab. gT the previous, 3gt tab 3." },
        { cmd = ":tabclose", at = "windows/tabs", label = "close tab", desc = "Closes the tab and its windows." },
    },
}
