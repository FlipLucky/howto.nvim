-- Vim's edit grammar, written once: verb + (modifier) + noun.
-- `for_verb` turns one verb into the tree verb → noun → modifier, with every key spelled out,
-- so delete/change/yank/select stay consistent and teach the same pattern.
local M = {}

M.verbs = {
    d = { name = "delete", does = "Deletes" },
    c = { name = "change", does = "Deletes and starts Insert mode for" },
    y = { name = "yank", does = "Copies (yanks)" },
    v = { name = "select", does = "Selects" },
}

-- Each noun: a list of { modifier label, suffix keys, parts after the verb, description }.
-- `%s` in a description is replaced by the verb's `does`.
M.nouns = {
    {
        id = "word", label = "word", letter = "w",
        desc = "A word: letters, digits and underscores.",
        forms = {
            { "to next word", "w", { { "w", "to next word" } }, "%s from the cursor to the start of the next word." },
            { "to end of word", "e", { { "e", "to end of word" } }, "%s from the cursor to the end of this word." },
            { "back to word start", "b", { { "b", "back to word start" } }, "%s from the cursor back to the start of the word." },
            { "inner · whole word", "iw", { { "i", "inner" }, { "w", "word" } }, "%s the whole word, wherever the cursor is in it." },
            { "around · word + space", "aw", { { "a", "around" }, { "w", "word" } }, "%s the whole word plus the space after it." },
        },
    },
    {
        id = "WORD", label = "WORD (to whitespace)", letter = "W",
        desc = "A WORD runs to the next whitespace: foo.bar(x) is one WORD.",
        forms = {
            { "to next WORD", "W", { { "W", "to next WORD" } }, "%s from the cursor to the next WORD (only whitespace separates)." },
            { "to end of WORD", "E", { { "E", "to end of WORD" } }, "%s from the cursor to the end of this WORD." },
            { "back to WORD start", "B", { { "B", "back to WORD start" } }, "%s from the cursor back to the start of the WORD." },
            { "inner · whole WORD", "iW", { { "i", "inner" }, { "W", "WORD" } }, "%s the whole WORD, e.g. all of foo.bar(x)." },
            { "around · WORD + space", "aW", { { "a", "around" }, { "W", "WORD" } }, "%s the whole WORD plus the space after it." },
        },
    },
    {
        id = "sentence", label = "sentence", letter = "s",
        desc = "Text up to a . ! or ? followed by a space or line end.",
        forms = {
            { "to next sentence", ")", { { ")", "to next sentence" } }, "%s from the cursor to the start of the next sentence." },
            { "inner · this sentence", "is", { { "i", "inner" }, { "s", "sentence" } }, "%s the sentence the cursor is in." },
            { "around · sentence + space", "as", { { "a", "around" }, { "s", "sentence" } }, "%s the sentence plus the space after it." },
        },
    },
    {
        id = "paragraph", label = "paragraph", letter = "p",
        desc = "Lines between blank lines. In code: a block of lines.",
        forms = {
            { "to end of paragraph", "}", { { "}", "to paragraph end" } }, "%s from the cursor to the next blank line." },
            { "inner · this paragraph", "ip", { { "i", "inner" }, { "p", "paragraph" } }, "%s the paragraph (block of lines) the cursor is in." },
            { "around · + blank line", "ap", { { "a", "around" }, { "p", "paragraph" } }, "%s the paragraph plus the blank line after it." },
        },
    },
    {
        id = "quotes", label = "quotes", letter = "\"",
        desc = "Text in \" ' or ` quotes. Works from anywhere on the line, also before the quotes.",
        forms = {
            { "inner \"", "i\"", { { "i", "inner" }, { "\"", "double quotes" } }, "%s the text inside \"…\"; the quotes stay." },
            { "around \"", "a\"", { { "a", "around" }, { "\"", "double quotes" } }, "%s the text and the \"…\" quotes." },
            { "inner '", "i'", { { "i", "inner" }, { "'", "single quotes" } }, "%s the text inside '…'; the quotes stay." },
            { "around '", "a'", { { "a", "around" }, { "'", "single quotes" } }, "%s the text and the '…' quotes." },
            { "inner `", "i`", { { "i", "inner" }, { "`", "backticks" } }, "%s the text inside `…`; the backticks stay." },
            { "around `", "a`", { { "a", "around" }, { "`", "backticks" } }, "%s the text and the `…` backticks." },
        },
    },
    {
        id = "brackets", label = "brackets", letter = "(",
        desc = "Text in (), [], {} or <>. Works from anywhere inside, also across lines.",
        forms = {
            { "inner ( )", "i(", { { "i", "inner" }, { "(", "parentheses" } }, "%s everything inside ( ); same as ib." },
            { "around ( )", "a(", { { "a", "around" }, { "(", "parentheses" } }, "%s the ( ) and everything inside." },
            { "inner [ ]", "i[", { { "i", "inner" }, { "[", "square brackets" } }, "%s everything inside [ ]." },
            { "around [ ]", "a[", { { "a", "around" }, { "[", "square brackets" } }, "%s the [ ] and everything inside." },
            { "inner { }", "i{", { { "i", "inner" }, { "{", "braces" } }, "%s everything inside { }; same as iB." },
            { "around { }", "a{", { { "a", "around" }, { "{", "braces" } }, "%s the { } and everything inside." },
            { "inner < >", "i<", { { "i", "inner" }, { "<", "angle brackets" } }, "%s everything inside < >." },
            { "around < >", "a<", { { "a", "around" }, { "<", "angle brackets" } }, "%s the < > and everything inside." },
        },
    },
    {
        id = "tag", label = "HTML/XML tag", letter = "t",
        desc = "The content of an element like <div>…</div>.",
        forms = {
            { "inner · tag content", "it", { { "i", "inner" }, { "t", "tag" } }, "%s the content between the opening and closing tag." },
            { "around · whole element", "at", { { "a", "around" }, { "t", "tag" } }, "%s the whole element, tags included." },
        },
    },
    {
        id = "char", label = "up to a character", letter = "f",
        desc = "Up to the next (or previous) occurrence of a character on this line. Replace {c} with the character.",
        forms = {
            { "till · up to {c}", "t{c}", { { "t", "till" }, { "{c}", "the character" } }, "%s up to, but not including, the next {c}." },
            { "find · including {c}", "f{c}", { { "f", "find" }, { "{c}", "the character" } }, "%s up to and including the next {c}." },
            { "till back · to after {c}", "T{c}", { { "T", "till backwards" }, { "{c}", "the character" } }, "%s back to just after the previous {c}." },
            { "find back · including {c}", "F{c}", { { "F", "find backwards" }, { "{c}", "the character" } }, "%s back to and including the previous {c}." },
        },
    },
    {
        id = "search", label = "up to a search match", letter = "/",
        desc = "Up to where a search lands. Any motion works after a verb.",
        forms = {
            { "to the next match", "/{text}<CR>", { { "/", "search" }, { "{text}", "what to find" }, { "<CR>", "go" } }, "%s from the cursor up to the next match of {text}." },
            { "next match", "gn", { { "gn", "next match" } }, "%s the next match of the last search. Repeat with . for each next match." },
        },
    },
}

-- Line forms differ per verb, so they are listed per verb.
M.lines = {
    d = {
        { "whole line", "dd", { { "d", "delete" }, { "d", "line (verb twice)" } }, "Deletes the whole line. A count deletes more: 3dd." },
        { "to line end", "D", { { "D", "delete to end" } }, "Deletes from the cursor to the end of the line (same as d$)." },
        { "to line start", "d0", { { "d", "delete" }, { "0", "line start" } }, "Deletes from the cursor back to the start of the line." },
    },
    c = {
        { "whole line", "cc", { { "c", "change" }, { "c", "line (verb twice)" } }, "Empties the line (keeps indent) and starts Insert mode." },
        { "to line end", "C", { { "C", "change to end" } }, "Changes from the cursor to the end of the line (same as c$)." },
        { "to line start", "c0", { { "c", "change" }, { "0", "line start" } }, "Changes from the cursor back to the start of the line." },
    },
    y = {
        { "whole line", "yy", { { "y", "yank" }, { "y", "line (verb twice)" } }, "Copies the whole line. Paste it below with p." },
        { "to line end", "Y", { { "Y", "yank to end" } }, "Copies from the cursor to the end of the line (Neovim default, same as y$)." },
        { "to line start", "y0", { { "y", "yank" }, { "0", "line start" } }, "Copies from the cursor back to the start of the line." },
    },
    v = {
        { "whole line", "V", { { "V", "select lines" } }, "Selects the whole line; move up/down to add lines." },
        { "to line end", "v$", { { "v", "select" }, { "$", "line end" } }, "Selects from the cursor to the end of the line." },
        { "to line start", "v0", { { "v", "select" }, { "0", "line start" } }, "Selects from the cursor back to the start of the line." },
    },
}

local function also_for(verb, suffix)
    local out = {}
    for _, v in ipairs({ "d", "c", "y", "v" }) do
        if v ~= verb then
            table.insert(out, v .. suffix)
        end
    end
    return out
end

--- Nodes and entries for one verb under `base` (e.g. "edit/delete").
function M.for_verb(verb, base)
    local nodes, entries = {}, {}
    local info = M.verbs[verb]
    local function add_noun(id, label, letter, desc)
        table.insert(nodes, { path = base .. "/" .. id, label = label, letter = letter, desc = desc })
    end
    for _, noun in ipairs(M.nouns) do
        add_noun(noun.id, noun.label, noun.letter, noun.desc)
        for _, f in ipairs(noun.forms) do
            local parts = { { verb, info.name } }
            vim.list_extend(parts, vim.deepcopy(f[3]))
            local desc = f[4]:format(info.does)
            if verb == "c" and f[2] == "w" then
                desc = "Changes from the cursor to the end of the word (cw acts like ce, the space stays)."
            end
            local also = (f[2]:match("^[ia]") or f[2] == "gn") and also_for(verb, f[2]) or nil
            table.insert(entries, {
                keys = verb .. f[2],
                at = base .. "/" .. noun.id,
                label = f[1],
                desc = desc,
                parts = parts,
                also = also,
            })
        end
    end
    add_noun("line", "line", "_", "Whole lines, or from the cursor to the start or end of the line.")
    for _, f in ipairs(M.lines[verb]) do
        table.insert(entries, { keys = f[2], at = base .. "/line", label = f[1], desc = f[4], parts = f[3] })
    end
    return nodes, entries
end

return M
