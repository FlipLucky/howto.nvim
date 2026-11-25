-- Vim regex: works in / searches, :s, :g and :v.
return {
    nodes = {
        { path = "patterns", label = "Patterns (regex)", order = 6, desc = "Vim's regex, for / search, :s, :g and :v. Start with \\v and it reads like other regex flavours." },
        { path = "patterns/basics", label = "basics", letter = "." },
        { path = "patterns/groups", label = "groups & reuse", letter = "\\1" },
        { path = "patterns/position", label = "match only part", letter = "\\zs" },
        { path = "patterns/replace", label = "in the replacement", letter = "&" },
    },
    entries = {
        { cmd = "\\v", at = "patterns/basics", label = "very magic", desc = "Put \\v at the start and ( ) | + ? { } work like in other regex, without backslashes: /\\v(foo|bar)+" },
        { cmd = ".  *  \\+  \\=", at = "patterns/basics", label = "any char, repeats", desc = ". any character, * zero or more, \\+ one or more, \\= zero or one. With \\v: . * + ?" },
        { cmd = "\\{-}", at = "patterns/basics", label = "lazy (as few as possible)", desc = "Matches as little as possible: \".\\{-}\" stops at the first closing quote. With \\v: .{-}" },
        { cmd = "\\{2,4}", at = "patterns/basics", label = "between n and m times", desc = "Repeats 2 to 4 times. \\{3} exactly 3. With \\v: {2,4}" },
        { cmd = "^  $", at = "patterns/basics", label = "line start / end", desc = "^ the start of the line, $ the end." },
        { cmd = "\\<  \\>", at = "patterns/basics", label = "whole word only", desc = "\\<cat\\> matches cat but not category. With \\v: <cat>" },
        { cmd = "[abc]  [^abc]", at = "patterns/basics", label = "one of / none of", desc = "[abc] one of these characters, [^abc] any other. [a-z] a range." },
        { cmd = "\\d \\s \\w \\a", at = "patterns/basics", label = "digit, space, word, letter", desc = "\\d digit, \\s whitespace, \\w word character, \\a letter. Capital = the opposite: \\D, \\S…" },
        { cmd = "\\n", at = "patterns/basics", label = "newline (in a pattern)", desc = "Matches a line break, so a pattern can span lines: /foo\\nbar" },

        { cmd = "\\(…\\)", at = "patterns/groups", label = "group", desc = "Groups part of the pattern so you can reuse it as \\1. With \\v just ( )." },
        { cmd = "\\|", at = "patterns/groups", label = "or", desc = "foo\\|bar matches either. With \\v: foo|bar" },
        { cmd = ":%s/\\v(\\w+) (\\w+)/\\2 \\1/", at = { "patterns/groups", "search/replace" }, label = "swap two words", desc = "Captures two words and writes them back swapped.", parts = { { ":%s/", "substitute" }, { "\\v", "very magic" }, { "(\\w+) (\\w+)", "two groups" }, { "/\\2 \\1/", "write them swapped" } } },

        { cmd = "\\zs  \\ze", at = "patterns/position", label = "match only part", desc = "Everything is required, but only the part between \\zs and \\ze is the match: /foo\\zsbar finds bar only after foo." },
        { cmd = "\\(…\\)\\@=", at = "patterns/position", label = "followed by (lookahead)", desc = "foo\\(bar\\)\\@= matches foo only when bar follows. \\@! = not followed by. With \\v: foo(bar)@=" },
        { cmd = "\\(…\\)\\@<=", at = "patterns/position", label = "preceded by (lookbehind)", desc = "\\(foo\\)\\@<=bar matches bar only after foo. \\@<! = not preceded by. \\zs is usually simpler." },

        { cmd = "&", at = "patterns/replace", label = "the whole match", desc = "In the replacement, & is what was matched: :s/\\d\\+/(&)/ wraps numbers in ( )." },
        { cmd = "\\1", at = "patterns/replace", label = "a group", desc = "\\1 is the first ( ) group, \\2 the second, …" },
        { cmd = "\\r", at = "patterns/replace", label = "newline (in a replacement)", desc = "In the replacement, \\r inserts a line break (\\n would insert a null byte): :s/, /,\\r/g" },
        { cmd = "\\u  \\U  \\L", at = "patterns/replace", label = "change case", desc = "\\u uppercases the next character, \\U…\\E everything up to \\E, \\L lowercase: :s/\\w\\+/\\u&/g capitalises words." },
        { cmd = "\\=", at = "patterns/replace", label = "an expression", desc = "\\= makes the replacement a Vim expression: :%s/\\d\\+/\\=submatch(0)*2/g doubles every number." },
    },
}
