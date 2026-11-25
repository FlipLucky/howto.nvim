-- mini.surround: add, delete and replace surrounding quotes/brackets/tags. Default mappings.
return {
    plugin = { "mini.surround", "mini.nvim" },
    name = "mini.surround",
    nodes = {
        { path = "edit/surround", label = "surround (mini.surround)", letter = "s" },
    },
    entries = {
        { keys = "saiw)", at = "edit/surround", label = "add around a word", desc = "sa + an object + the character: wraps the word in ( ). ( adds spaces inside, ) doesn't.", parts = { { "sa", "surround add" }, { "iw", "inner word" }, { ")", "with ( )" } } },
        { keys = "sa", mode = "x", at = "edit/surround", label = "add around the selection", desc = "Select first, then sa + the character." },
        { keys = "sd\"", at = "edit/surround", label = "delete surrounding quotes", desc = "Removes the \" around the cursor; the text stays.", parts = { { "sd", "surround delete" }, { "\"", "which surrounding" } } },
        { keys = "sr)]", at = "edit/surround", label = "replace ( ) with [ ]", desc = "sr + the old character + the new one.", parts = { { "sr", "surround replace" }, { ")", "old" }, { "]", "new" } } },
        { keys = "saiwt", at = "edit/surround", label = "wrap in an HTML tag", desc = "t asks for the tag name: div gives <div>word</div>.", parts = { { "sa", "surround add" }, { "iw", "inner word" }, { "t", "tag (asks name)" } } },
        { keys = "sf)", at = "edit/surround", label = "find the next surrounding", desc = "Jumps to the next ( ). sF searches to the left, sh highlights it.", parts = { { "sf", "surround find" }, { ")", "which" } } },
    },
}
