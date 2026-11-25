-- grug-far.nvim: search and replace across files with a live preview.
return {
    plugin = "grug-far.nvim",
    entries = {
        { cmd = ":GrugFar", at = { "search/files", "search/replace" }, label = "find & replace in the project", desc = "Opens a buffer where you type search, replacement and file filters; matches update as you type. Its own keys use <localleader>: r to replace, g? for help." },
        { cmd = ":GrugFarWithin", at = { "search/replace", "many-lines" }, label = "find & replace in the selection", desc = "Like :GrugFar, but only inside the lines you selected." },
        { steps = { { ":GrugFar", "open it" }, { "{search}", "type what to find (ripgrep regex)" }, { "{replace}", "type the replacement; the diff shows live" }, { "<localleader>r", "replace all" }, { "<localleader>q", "or send the results to quickfix instead" } }, at = "search/files", label = "replace across files, previewed", desc = "Unlike :cdo you see every change before it happens." },
    },
}
