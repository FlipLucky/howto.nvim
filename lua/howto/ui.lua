-- The browser: one floating window, one scratch buffer, rendered as text.
-- Up to three Miller columns (path levels + a preview of the selected node) and a strip at the
-- bottom that explains the selected item.
local registry = require("howto.registry")

local M = {}
local api = vim.api
local ns = api.nvim_create_namespace("howto")

local SEP = " │ "
local MODE_PREFIX = { x = "v ", v = "v ", i = "i ", o = "o ", c = "c ", t = "t " }
local PART_HL = { "HowtoPart1", "HowtoPart2", "HowtoPart3", "HowtoPart4" }

local function set_highlights()
    local links = {
        HowtoNormal = "NormalFloat",
        HowtoBorder = "FloatBorder",
        HowtoTitle = "FloatTitle",
        HowtoSelected = "PmenuSel",
        HowtoPath = "Visual",
        HowtoNode = "Directory",
        HowtoLetter = "Special",
        HowtoKey = "Function",
        HowtoDim = "Comment",
        HowtoSep = "FloatBorder",
        HowtoPart1 = "DiagnosticInfo",
        HowtoPart2 = "DiagnosticWarn",
        HowtoPart3 = "DiagnosticOk",
        HowtoPart4 = "DiagnosticHint",
    }
    for group, target in pairs(links) do
        api.nvim_set_hl(0, group, { link = target, default = true })
    end
end

-- state: { win, buf, prev_win, tree, stack = { { node, idx, top } }, augroup }
local S = nil

----------------------------------------------------------------------
-- Text cells: a cell is a list of segments { text, hl? }, fitted to a display width.
----------------------------------------------------------------------
local dw = vim.fn.strdisplaywidth

-- Cut text to at most `width` display cells.
local function cut(text, width)
    local out, w = "", 0
    for _, ch in ipairs(vim.fn.split(text, "\\zs")) do
        local chw = dw(ch)
        if w + chw > width then
            break
        end
        out, w = out .. ch, w + chw
    end
    return out, w
end

-- Fit segments into exactly `width` cells: pad when short, cut with "…" when too long.
local function fit(segs, width)
    local total = 0
    for _, seg in ipairs(segs) do
        total = total + dw(seg[1])
    end
    local out, used = {}, 0
    if total <= width then
        for _, seg in ipairs(segs) do
            table.insert(out, { seg[1], seg[2] })
        end
        used = total
    else
        local budget = math.max(0, width - 1)
        for _, seg in ipairs(segs) do
            local w = dw(seg[1])
            if used + w <= budget then
                table.insert(out, { seg[1], seg[2] })
                used = used + w
            else
                local part, pw = cut(seg[1], budget - used)
                table.insert(out, { part .. (width > 0 and "…" or ""), seg[2] })
                used = used + pw + (width > 0 and 1 or 0)
                break
            end
        end
    end
    if used < width then
        table.insert(out, { string.rep(" ", width - used) })
    end
    return out
end

-- Join cells into one line; returns text and highlight ranges { start_byte, end_byte, hl }.
local function join(cells)
    local text, hls = "", {}
    for _, cell in ipairs(cells) do
        for _, seg in ipairs(cell) do
            if seg[2] and seg[1] ~= "" then
                table.insert(hls, { #text, #text + #seg[1], seg[2] })
            end
            text = text .. seg[1]
        end
    end
    return text, hls
end

----------------------------------------------------------------------
-- Items
----------------------------------------------------------------------
local function key_text(e)
    if e.kind == "keys" then
        return (MODE_PREFIX[e.mode] or "") .. e.keys
    elseif e.kind == "cmd" then
        return e.cmd
    end
    return ""
end

local function item_segments(item, width, key_w)
    if item.node then
        local n = item.node
        local segs = {}
        if n.letter then
            table.insert(segs, { n.letter, "HowtoLetter" })
            table.insert(segs, { "  " })
        end
        table.insert(segs, { n.label, "HowtoNode" })
        local used = 0
        for _, s in ipairs(segs) do
            used = used + dw(s[1])
        end
        local gap = math.max(1, width - used - 1)
        table.insert(segs, { string.rep(" ", gap) })
        table.insert(segs, { "›", "HowtoDim" })
        -- When too narrow, keep the label and drop the arrow first.
        if used + 2 > width then
            segs[#segs], segs[#segs - 1] = nil, nil
        end
        return segs
    end
    local e = item.entry
    if e.kind == "steps" then
        return { { "⋯ ", "HowtoDim" }, { e.label } }
    end
    local k = key_text(e)
    if dw(k) > key_w and key_w > 1 then
        k = cut(k, key_w - 1) .. "…"
    end
    local pad = math.max(0, key_w - dw(k))
    return { { k, "HowtoKey" }, { string.rep(" ", pad) .. "  " }, { e.label } }
end

local function column_key_width(items, width)
    local w = 0
    for _, it in ipairs(items) do
        if it.entry and it.entry.kind ~= "steps" then
            w = math.max(w, dw(key_text(it.entry)))
        end
    end
    return math.min(w, math.floor(width * 0.5))
end

----------------------------------------------------------------------
-- Layout
----------------------------------------------------------------------
local function layout()
    local cols, lines = vim.o.columns, vim.o.lines
    local width = math.max(20, math.min(cols - 4, 120))
    local height = math.max(8, math.min(lines - 4, 30))
    local strip_h = math.max(3, math.min(7, math.floor(height * 0.35)))
    return {
        width = width,
        height = height,
        strip_h = strip_h,
        rows = height - strip_h - 1,
        row = math.floor((lines - height) / 2) - 1,
        col = math.floor((cols - width) / 2),
    }
end

local function current()
    return S.stack[#S.stack]
end

local function selected_item()
    local lvl = current()
    return lvl.node.items[lvl.idx]
end

local function crumbs()
    local labels = {}
    for i = 2, #S.stack do
        table.insert(labels, S.stack[i].node.label)
    end
    return labels
end

local function title()
    local c = crumbs()
    if #c == 0 then
        return " Howto "
    end
    return " Howto ── " .. table.concat(c, " › ") .. " "
end

----------------------------------------------------------------------
-- Strip
----------------------------------------------------------------------
local function wrap(text, width)
    local out, line = {}, ""
    for word in text:gmatch("%S+") do
        if line == "" then
            line = word
        elseif dw(line) + 1 + dw(word) <= width then
            line = line .. " " .. word
        else
            table.insert(out, line)
            line = word
        end
    end
    if line ~= "" then
        table.insert(out, line)
    end
    return out
end

local function strip_lines(width)
    local item = selected_item()
    local out = {} -- list of segment lists
    if not item then
        return out
    end
    if item.node then
        local n = item.node
        table.insert(out, { { n.label, "HowtoNode" }, { "   " }, { #n.items .. " items · l to open", "HowtoDim" } })
        for _, l in ipairs(wrap(n.desc or "", width)) do
            table.insert(out, { { l } })
        end
        return out
    end
    local e = item.entry
    local first = {}
    if e.kind == "steps" then
        table.insert(first, { e.label, "HowtoNode" })
    else
        local k = key_text(e)
        local colored = false
        if e.kind == "keys" and e.parts then
            local spelled = table.concat(vim.tbl_map(function(p) return p[1] end, e.parts))
            if spelled == e.keys then
                colored = true
                if MODE_PREFIX[e.mode] then
                    table.insert(first, { MODE_PREFIX[e.mode], "HowtoDim" })
                end
                for i, p in ipairs(e.parts) do
                    table.insert(first, { p[1], PART_HL[(i - 1) % #PART_HL + 1] })
                end
            end
        end
        if not colored then
            table.insert(first, { k, "HowtoKey" })
        end
        if e.parts then
            table.insert(first, { "   " })
            for i, p in ipairs(e.parts) do
                if i > 1 then
                    table.insert(first, { "  " })
                end
                table.insert(first, { p[1], PART_HL[(i - 1) % #PART_HL + 1] })
                table.insert(first, { "=" .. p[2], "HowtoDim" })
            end
        end
    end
    table.insert(first, { "   · " .. e.source, "HowtoDim" })
    table.insert(out, first)

    if e.kind == "steps" then
        for i, s in ipairs(e.steps) do
            table.insert(out, { { ("%d. "):format(i), "HowtoDim" }, { s[1], "HowtoKey" }, { "  " .. s[2] } })
        end
    end
    if e.desc and (e.kind ~= "steps" or e.desc ~= e.label) then
        for _, l in ipairs(wrap(e.desc, width)) do
            table.insert(out, { { l } })
        end
    end
    if e.also and #e.also > 0 then
        local also = { { "Also: ", "HowtoDim" } }
        for i, a in ipairs(e.also) do
            table.insert(also, { (i > 1 and "  " or "") .. a, "HowtoKey" })
        end
        table.insert(out, also)
    end
    return out
end

----------------------------------------------------------------------
-- Render
----------------------------------------------------------------------
local function visible_columns()
    local cols = {}
    for i, lvl in ipairs(S.stack) do
        table.insert(cols, { node = lvl.node, level = lvl, focused = i == #S.stack, on_path = i < #S.stack })
    end
    local item = selected_item()
    if item and item.node then
        table.insert(cols, { node = item.node, preview = true })
    end
    while #cols > 3 do
        table.remove(cols, 1)
    end
    return cols
end

local function render()
    if not S or not api.nvim_win_is_valid(S.win) then
        return
    end
    local L = layout()
    S.layout = L
    api.nvim_win_set_config(S.win, {
        relative = "editor",
        row = L.row,
        col = L.col,
        width = L.width,
        height = L.height,
        title = title(),
        title_pos = "left",
        footer = L.width >= 60 and " j/k move  l open  h back  - intents  / search  q close " or " q close ",
        footer_pos = "right",
    })

    -- Path columns are narrow; the last visible column (keys or preview) takes the rest.
    local cols = visible_columns()
    local ncol = math.max(1, #cols)
    local avail = L.width - (ncol - 1) * dw(SEP)
    local widths = {}
    for c = 1, ncol - 1 do
        widths[c] = math.floor(avail * 0.28)
    end
    local used = 0
    for _, w in ipairs(widths) do
        used = used + w
    end
    widths[ncol] = avail - used
    local lines, hls = {}, {}
    local cursor_row = 1

    -- Keep the focused selection visible.
    local lvl = current()
    if lvl.idx < lvl.top then
        lvl.top = lvl.idx
    elseif lvl.idx > lvl.top + L.rows - 1 then
        lvl.top = lvl.idx - L.rows + 1
    end

    for row = 1, L.rows do
        local cells = {}
        for c = 1, ncol do
            local col = cols[c]
            local w = widths[c]
            local segs
            if col then
                local items = col.node.items
                local top = col.level and col.level.top or 1
                local i = top + row - 1
                local item = items[i]
                if item then
                    local is_sel = col.level and col.level.idx == i
                    local marker = (col.focused and is_sel) and "▌" or " "
                    local inner = item_segments(item, w - 1, column_key_width(items, w - 1))
                    segs = fit({ { marker, "HowtoLetter" }, unpack(inner) }, w)
                    if is_sel then
                        local hl = col.focused and "HowtoSelected" or "HowtoPath"
                        segs.row_hl = hl
                    end
                    if col.focused and is_sel then
                        cursor_row = row
                    end
                elseif row == 1 and #items == 0 then
                    segs = fit({ { " No matches", "HowtoDim" } }, w)
                end
            end
            segs = segs or fit({}, w)
            table.insert(cells, segs)
            if c < ncol then
                table.insert(cells, { { SEP, "HowtoSep" } })
            end
        end
        local text, line_hls = join(cells)
        -- Selection background over the whole cell of a selected item.
        local byte = 0
        for _, cell in ipairs(cells) do
            local len = 0
            for _, s in ipairs(cell) do
                len = len + #s[1]
            end
            if cell.row_hl then
                table.insert(line_hls, 1, { byte, byte + len, cell.row_hl })
            end
            byte = byte + len
        end
        table.insert(lines, text)
        table.insert(hls, line_hls)
    end

    -- Strip.
    local sep_line = string.rep("─", L.width)
    table.insert(lines, sep_line)
    table.insert(hls, { { 0, #sep_line, "HowtoSep" } })
    local strip = strip_lines(L.width - 2)
    for i = 1, L.strip_h do
        local segs = strip[i]
        local text, line_hls = join({ fit(segs and { { " " }, unpack(segs) } or {}, L.width) })
        table.insert(lines, text)
        table.insert(hls, line_hls)
    end

    vim.bo[S.buf].modifiable = true
    api.nvim_buf_set_lines(S.buf, 0, -1, false, lines)
    vim.bo[S.buf].modifiable = false
    api.nvim_buf_clear_namespace(S.buf, ns, 0, -1)
    for r, line_hls in ipairs(hls) do
        for _, hl in ipairs(line_hls) do
            api.nvim_buf_set_extmark(S.buf, ns, r - 1, hl[1], { end_col = hl[2], hl_group = hl[3], priority = hl[3] == "HowtoSelected" and 90 or 100 })
        end
    end
    pcall(api.nvim_win_set_cursor, S.win, { cursor_row, 0 })
end

----------------------------------------------------------------------
-- Actions
----------------------------------------------------------------------
local function move(delta)
    local lvl = current()
    local n = #lvl.node.items
    if n == 0 then
        return
    end
    lvl.idx = math.max(1, math.min(n, lvl.idx + delta))
    render()
end

local function go_to(idx)
    local lvl = current()
    if #lvl.node.items > 0 then
        lvl.idx = math.max(1, math.min(#lvl.node.items, idx))
        render()
    end
end

local function open_selected()
    local item = selected_item()
    if item and item.node and #item.node.items > 0 then
        table.insert(S.stack, { node = item.node, idx = 1, top = 1 })
        render()
    end
end

local function back()
    if #S.stack > 1 then
        table.remove(S.stack)
        render()
    end
end

local function to_root()
    while #S.stack > 1 do
        table.remove(S.stack)
    end
    render()
end

function M.close()
    if not S then
        return
    end
    local s = S
    S = nil
    pcall(api.nvim_del_augroup_by_id, s.augroup)
    if api.nvim_win_is_valid(s.win) then
        pcall(api.nvim_win_close, s.win, true)
    end
    if s.prev_win and api.nvim_win_is_valid(s.prev_win) then
        pcall(api.nvim_set_current_win, s.prev_win)
    end
end

local function search()
    vim.ui.input({ prompt = "Howto search: " }, function(query)
        if not S or not query or vim.trim(query) == "" then
            return
        end
        local results = registry.search(S.tree, query)
        local items = vim.tbl_map(function(e) return { entry = e } end, results)
        local node = { label = "Search: " .. query, items = items, children = {}, entries = results }
        table.insert(S.stack, { node = node, idx = 1, top = 1 })
        if S.win and api.nvim_win_is_valid(S.win) then
            api.nvim_set_current_win(S.win)
        end
        render()
    end)
end

local function map_keys(buf)
    local function m(keys, fn)
        for _, k in ipairs(keys) do
            vim.keymap.set("n", k, fn, { buffer = buf, nowait = true, silent = true })
        end
    end
    m({ "j", "<Down>" }, function() move(vim.v.count1) end)
    m({ "k", "<Up>" }, function() move(-vim.v.count1) end)
    m({ "l", "<CR>", "<Right>" }, open_selected)
    m({ "h", "<BS>", "<Left>" }, back)
    m({ "-" }, to_root)
    m({ "G" }, function() go_to(math.huge) end)
    m({ "gg" }, function() go_to(1) end)
    m({ "<C-d>" }, function() move(math.floor(S.layout.rows / 2)) end)
    m({ "<C-u>" }, function() move(-math.floor(S.layout.rows / 2)) end)
    m({ "/" }, search)
    m({ "q", "<Esc>" }, M.close)
end

----------------------------------------------------------------------
-- Open
----------------------------------------------------------------------
local function stack_for(root, path)
    local stack = { { node = root, idx = 1, top = 1 } }
    if not path or path == "" then
        return stack
    end
    local node = root
    local prefix = ""
    for seg in path:gmatch("[^/]+") do
        prefix = prefix == "" and seg or (prefix .. "/" .. seg)
        local found
        for i, it in ipairs(node.items) do
            if it.node and it.node.path == prefix then
                found = i
                break
            end
        end
        if not found then
            vim.notify("howto: no such place: " .. path, vim.log.levels.WARN)
            break
        end
        stack[#stack].idx = found
        node = node.items[found].node
        table.insert(stack, { node = node, idx = 1, top = 1 })
    end
    return stack
end

function M.open(path)
    if S and api.nvim_win_is_valid(S.win) then
        api.nvim_set_current_win(S.win)
        return
    end
    set_highlights()
    local tree = registry.get()
    if #tree.problems > 0 and not tree.reported then
        tree.reported = true
        vim.notify("howto: skipped invalid content (see :checkhealth howto)\n" .. table.concat(tree.problems, "\n"), vim.log.levels.WARN)
    end

    local buf = api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "howto"
    local L = layout()
    local prev = api.nvim_get_current_win()
    local win = api.nvim_open_win(buf, true, {
        relative = "editor",
        row = L.row,
        col = L.col,
        width = L.width,
        height = L.height,
        style = "minimal",
        border = "rounded",
        title = " Howto ",
        zindex = 60,
    })
    vim.wo[win].winhighlight = "NormalFloat:HowtoNormal,FloatBorder:HowtoBorder,FloatTitle:HowtoTitle"
    vim.wo[win].wrap = false
    vim.wo[win].cursorline = false

    S = { win = win, buf = buf, prev_win = prev, tree = tree, stack = stack_for(tree.root, path) }
    S.augroup = api.nvim_create_augroup("howto_window", { clear = true })
    api.nvim_create_autocmd("WinEnter", {
        group = S.augroup,
        callback = function()
            if S and api.nvim_get_current_win() ~= S.win then
                S.prev_win = nil -- the user went somewhere on purpose; don't pull focus back
                M.close()
            end
        end,
    })
    api.nvim_create_autocmd("VimResized", { group = S.augroup, callback = render })
    api.nvim_create_autocmd("BufWipeout", {
        group = S.augroup,
        buffer = buf,
        callback = function()
            if S and S.buf == buf then
                pcall(api.nvim_del_augroup_by_id, S.augroup)
                S = nil
            end
        end,
    })
    map_keys(buf)
    render()
end

return M
