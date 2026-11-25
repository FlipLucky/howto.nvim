# howto.nvim

Find Neovim keys, commands and recipes **by what you want to do**.

You know you want to *delete a word*, *edit many lines at once* or *replace across files*, but not
which keys do it. Search doesn't help when you don't know what to search for. howto starts from the
intent and narrows down, so you also discover what you didn't know existed.

```
╭─ Howto ── Edit › delete › word ──────────────────────────────────────────────╮
│ d  delete               › │  w  word                 › │  dw   to next word    │
│ c  change               › │  W  WORD (to whitespace) › │  de   to end of word  │
│ y  yank (copy)          › │  s  sentence             › │ ▌diw  inner · whole … │
│ p  paste                › │  p  paragraph            › │  daw  around · word … │
├──────────────────────────────────────────────────────────────────────────────┤
│ diw   d=delete  i=inner  w=word   · native                                    │
│ Deletes the whole word, wherever the cursor is in it.                         │
│ Also: ciw  yiw  viw                                                           │
╰──────────────────────────────────────────────────────────────────────────────╯
```

- **Intent first.** The first column is always *what do you want to do*: Move, Edit, Select, Search,
  Many lines at once, Patterns (regex), Undo, Jump back, Buffers, Windows, Code (LSP), Lists, Folds,
  Registers & macros, Insert mode.
- **Vim's grammar, made visible.** Edits go verb → noun → modifier (`delete › word › inner`), and the
  strip shows how the keys are built: `d`=delete `i`=inner `w`=word. The same objects repeat under
  every verb on purpose: that's how the pattern sticks.
- **Not only keys.** Commands (`:g/pattern/d`), regex (`\zs`, `\{-}`) and multi-step recipes
  (visual block insert) live in the same tree.
- **Docs only.** howto never runs anything. You type it yourself; that's how you learn it.
- **Honest about your setup.** When your config or a plugin maps a key to something else
  (`<C-l>` → tmux navigation, `s` → disabled by mini.surround), the strip says
  `⚠ remapped here: …` and names who did it, instead of teaching a key that doesn't do that for you.
- **Your plugins too.** Plugins with a pack show up in their intents and under *Plugins*, but only
  when they're installed.

## Install

Neovim 0.10+ (0.12+ recommended: newer defaults are shown only when your Neovim has them).

```lua
-- vim.pack (Neovim 0.12+)
vim.pack.add({ { src = "https://github.com/FlipLucky/howto.nvim", version = vim.version.range("0.*") } })

-- lazy.nvim
{ "FlipLucky/howto.nvim", cmd = "Howto", version = "*" }
```

The version range keeps you on releases; leave it out to follow `main`. See [Compatibility](#compatibility).

No dependencies. No default keymap; pick one:

```lua
vim.keymap.set("n", "<leader>?", "<cmd>Howto<cr>", { desc = "Howto: find keys by intent" })
```

## Use

`:Howto` opens the intents. `:Howto edit/delete` opens at a place (Tab completes).

| key | |
|---|---|
| `j` / `k` | move in the column; the next column previews what's inside |
| `l` / `<CR>` | go deeper |
| `h` / `<BS>` | go back |
| `-` | back to the intents |
| `/` | search everything (keys, labels, descriptions) |
| `q` / `<Esc>` | close |

## Add your own

`setup()` is optional and only stores your table; nothing loads until you open howto.

```lua
require("howto").setup({
    nodes = {
        { path = "code", label = "LSP" },                        -- rename an intent
        { path = "mine/docker", label = "Docker" },             -- a new level
    },
    entries = {
        { keys = "<leader>fr", at = "search/replace", label = "replace in project",
          desc = "grug-far across files: strings and config the LSP can't rename." },
        { cmd = ":!docker compose up -d", at = "mine/docker", label = "start the stack" },
    },
})
```

Your entries show where you put them **and** under *Mine*.

### Entries

Exactly one of `keys`, `cmd` or `steps`:

```lua
{ keys = "diw", at = "edit/delete/word", label = "inner", desc = "…",
  parts = { { "d", "delete" }, { "i", "inner" }, { "w", "word" } },   -- spells the keys, coloured in the strip
  also = { "ciw", "yiw" }, mode = "n", has = "nvim-0.11" }

{ cmd = ":g/pattern/d", at = { "many-lines", "patterns" }, label = "…" }  -- several places, written once

{ steps = { { "<C-v>", "start a block" }, { "I", "insert" }, { "<Esc>", "applies to every line" } },
  at = "many-lines", label = "insert on many lines" }
```

- `at`: a path or a list of paths. A path that doesn't exist yet becomes a node.
- `mode`: `x` visual, `i` insert, `o` operator-pending, `c` command line (shown as a prefix).
- `has`: hide the entry when `vim.fn.has(has)` is false (e.g. keys added in a newer Neovim).
- `label` or `desc` is required.

### Nodes

`{ path = "edit/delete", label = "delete", letter = "d", order = 2, desc = "…" }`. `letter` is the
mnemonic shown before the label; `order` sorts the intents column.

## Plugin packs

A pack is a file in `lua/howto/packs/` that describes one plugin's keys. It's only loaded when that
plugin is installed (a runtimepath directory with that name, so any package manager works).

```lua
-- lua/howto/packs/oil.lua
return {
    plugin = "oil.nvim",                -- or a list: { "mini.ai", "mini.nvim" }
    nodes = { { path = "files", label = "Files (oil)", order = 9.5 } },
    entries = { { keys = "-", at = "files", label = "parent directory", desc = "…" } },
}
```

Packs for your plugin are welcome as pull requests: describe the default keys, place them in the
intents where people would look for them, and run the tests.

Included: gitlab.nvim, grug-far.nvim, mini.ai, mini.surround, oil.nvim.

## Health and tests

`:checkhealth howto` lists the active packs and anything invalid that was skipped.

```sh
nvim --clean -l tests/run.lua          # all tests, headless, no dependencies
nvim --clean -l tests/run.lua search   # only tests whose name contains "search"
```

## Compatibility

Releases follow [SemVer](https://semver.org) (`vX.Y.Z` tags, notes in [CHANGELOG.md](CHANGELOG.md)).
Tested on Neovim 0.10, the latest stable and nightly.

What counts as the API, so changing it is a breaking change:

- the `setup()` table: `nodes`, `entries` and their fields;
- the pack format (`plugin`, `name`, `nodes`, `entries`);
- `:Howto [path]` and the `Howto*` highlight groups;
- **the tree paths** (`edit/delete/word`, `search/replace`, …). Your entries and packs hang on them
  with `at`. A renamed path doesn't error: your entry would silently land in a new, empty node.
  So paths are only renamed in a breaking release, or the old path keeps working as an alias.

New intents, entries and packs, and fixes to their text, are not breaking.
While the version is 0.x, a breaking change bumps the minor version (0.1 → 0.2), so `0.*`
can still break: pin `0.1.*` if you'd rather not.

