# howto.nvim — design

Date: 2026-11-25. Status: approved in conversation (sections 1–2 explicitly, 3–5 under "go for gold, all in one go").

## Purpose

Find Neovim keys, commands and recipes **by intent**, for people who don't know what to look up.
You think "I want to move / delete / replace on many lines", not "what does `diw` do". The tool starts
from the intent and narrows down, so you also discover actions you didn't know existed.

It is documentation only: it never runs anything. Typing the key yourself is how it sticks.

## Non-goals (MVP)

- Running or inserting the selected action.
- Hiding entries, a vim.pack adapter (version/URL), auto-filling from detected keymaps (nice-to-have later).
- Being a complete key reference: `:help index` already is one. The native set is curated.

## Navigation model

A tree with variable depth. The root is the list of intents (step 1 is always "what do you want to do").
Grammar intents follow verb → noun → modifier, with "none" as a modifier:
`Edit › delete › word › {dw, de, db, diw, daw}`. Repetition (inner, inner, inner…) is deliberate:
it teaches the pattern without requiring the user to understand it first.

Each node can carry a mnemonic `letter`; key entries carry `parts` that break the keys down in typed
order (`d`=delete `i`=inner `w`=word), coloured consistently in the bottom strip.

## UI

One floating window, one scratch buffer, rendered as text (no multi-window focus juggling):

```
╭─ Howto ── Edit › delete › word ──────────────────────────────╮
│ Move       │ delete    › │ dw   from cursor to next word     │
│ Edit     › │ change    › │ de   to end of word               │
│ Select     │ yank      › │▌diw  inner                        │
├──────────────────────────────────────────────────────────────┤
│ diw   d=delete  i=inner  w=word                     native   │
│ The whole word, wherever the cursor is in it.                │
│ Also: ciw  yiw  viw                                          │
╰──────────────────────────────────────────────────────────────╯
```

- Miller columns: up to three columns. The columns are the last three of
  `[levels on the path…, preview of the selected node]`; the focused column is the deepest level.
- Keys: `j`/`k` (`<Down>`/`<Up>`) move, `l`/`<CR>`/`<Right>` go deeper, `h`/`<BS>`/`<Left>` go back,
  `-` jumps to the intents, `/` searches all entries (results become a temporary level), `q`/`<Esc>` close.
- Breadcrumb in the title, key hints in the footer, the strip at the bottom for the selected item:
  key/command + parts + source, the description, "Also", or numbered steps for a recipe.
- Closes when focus leaves it; re-lays out on `VimResized`; opening twice focuses the existing one.
- Fits narrow screens: columns shrink and text is truncated with `…`, never overflowing.

## Data model

```lua
-- node (tree structure)
{ path = "edit/delete", label = "delete", letter = "d", order = 2, desc = "…", has = "nvim-0.13" }

-- entry: exactly one of keys / cmd / steps
{ keys = "diw", mode = "n", at = "edit/delete/word", label = "inner", desc = "…",
  parts = { { "d", "delete" }, { "i", "inner" }, { "w", "word" } }, also = { "ciw", "yiw" } }
{ cmd = ":g/pattern/d", at = { "many-lines", "patterns" }, label = "…", desc = "…", parts = { … } }
{ steps = { { "<C-v>", "start block selection" }, … }, at = "many-lines", label = "…", desc = "…" }
```

- `at`: one path or a list (one entry, several places, written once).
- `mode` (optional): `"x"` visual, `"i"` insert, `"o"` operator-pending, `"c"` command line; shown as a prefix.
- `has` (optional): a `vim.fn.has()` feature; the item is hidden when false (version-gated keys).
- `label` or `desc` is required; `label` defaults to `desc`.
- `source` is set by the loader: `native`, the pack's plugin name, or `mine`.

## Sources and merging

Loaded lazily on first open (`setup()` only stores the user table; zero startup cost), in order:

1. Native: `lua/howto/native/*.lua`, each returns `{ nodes = {}, entries = {} }`.
2. Packs: `lua/howto/packs/*.lua`, each also has `plugin = "name"` or a list of names; loaded only when
   a runtimepath directory with that name exists (works for any package manager).
3. User: `require("howto").setup({ nodes = {}, entries = {} })`.

Rules: same node path → later layer overrides label/letter/order/desc. Entries are always added.
Pack entries also appear under `Plugins › <plugin>`, user entries also under `Mine`; both roots only
show when non-empty. An `at` path without a node gets an implicit node labelled by its last segment.
Root intents sort by `order`; other levels keep insertion order (nodes first, then entries).

## Errors

- Invalid nodes/entries are skipped; a pack that fails to load is skipped. Problems are collected,
  reported once with `vim.notify` (WARN) on open, and listed by `:checkhealth howto`.
- Opening never throws because of content.

## Testing

Headless Neovim, `nvim -l tests/run.lua` (no dependencies). Tests drive the real UI with keys and assert
what the user sees (buffer lines, title, strip), plus loader behaviour:
navigation and back, breadcrumb, multi-placement, user setup + override + Mine, pack present/absent,
broken pack and invalid entry (warned, rest works), `has` gating, close/reopen/double open,
leaving the window, narrow screen, search, lazy loading (setup loads no content), and native content
integrity (all `at` paths declared, `parts` concatenate to `keys`).
