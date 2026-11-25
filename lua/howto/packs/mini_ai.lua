-- mini.ai: extra text objects for every verb (d, c, y, v…). Defaults from mini.ai's config.
return {
    plugin = { "mini.ai", "mini.nvim" },
    name = "mini.ai",
    nodes = {
        { path = "edit/objects", label = "more objects (mini.ai)", letter = "a/f" },
    },
    entries = {
        { keys = "daa", at = { "edit/objects", "edit/delete" }, label = "delete an argument", desc = "Deletes a function argument plus its comma: f(a, |b, c) → f(a, c).", parts = { { "d", "delete" }, { "a", "around" }, { "a", "argument" } }, also = { "cia", "yaa", "via" } },
        { keys = "cif", at = { "edit/objects", "edit/change" }, label = "change inside a function call", desc = "Changes the arguments of the call the cursor is in: f(|a, b) → f(…).", parts = { { "c", "change" }, { "i", "inner" }, { "f", "function call" } }, also = { "dif", "yaf", "vaf" } },
        { keys = "ciq", at = { "edit/objects", "edit/change" }, label = "change inside any quotes", desc = "q = whichever quotes are nearest (\" ' or `), so you don't have to say which.", parts = { { "c", "change" }, { "i", "inner" }, { "q", "any quote" } }, also = { "diq", "yaq", "viq" } },
        { keys = "dib", at = { "edit/objects", "edit/delete" }, label = "delete inside any brackets", desc = "b = the nearest (), [] or {}.", parts = { { "d", "delete" }, { "i", "inner" }, { "b", "any bracket" } }, also = { "cib", "yab", "vib" } },
        { keys = "vit", at = { "edit/objects", "select" }, label = "select inside a tag", desc = "mini.ai's tag object also finds the tag when the cursor is before it on the line.", parts = { { "v", "select" }, { "i", "inner" }, { "t", "tag" } } },
        { keys = "ci?", at = "edit/objects", label = "inside anything you type", desc = "Asks for the left and right edge, e.g. * and *: change inside *bold*.", parts = { { "c", "change" }, { "i", "inner" }, { "?", "ask for edges" } } },
        { keys = "cin(", at = "edit/objects", label = "inside the NEXT ( )", desc = "n = next: works from before the brackets. l = last (previous). Only when mini.ai's next/last mappings are enabled.", parts = { { "c", "change" }, { "i", "inner" }, { "n", "next" }, { "(", "parentheses" } } },
    },
}
