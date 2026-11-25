-- Loads native content, installed plugin packs and the user's setup(), validates and merges
-- them into one tree. Built once per session (or after setup()), on first use.
local M = {}

local ROOT_NODES = {
    { path = "plugins", label = "Plugins", order = 90, desc = "Keys from installed plugins that have a pack." },
    { path = "mine", label = "Mine", order = 99, desc = "Everything from your own setup()." },
}

local function last_segment(path)
    return path:match("([^/]+)$") or path
end

local function parent_of(path)
    return path:match("^(.*)/[^/]+$") or ""
end

local function supported(item)
    return item.has == nil or vim.fn.has(item.has) == 1
end

local function describe(item)
    return item.keys or item.cmd or item.label or item.path or "?"
end

local function is_pairs(list)
    if type(list) ~= "table" then
        return false
    end
    for _, p in ipairs(list) do
        if type(p) ~= "table" or type(p[1]) ~= "string" or type(p[2]) ~= "string" then
            return false
        end
    end
    return true
end

-- Returns an error message, or nil when the entry is valid.
local function validate_entry(e)
    if type(e) ~= "table" then
        return "is not a table"
    end
    local kinds = (e.keys and 1 or 0) + (e.cmd and 1 or 0) + (e.steps and 1 or 0)
    if kinds ~= 1 then
        return "needs exactly one of keys, cmd or steps"
    end
    if (e.keys and type(e.keys) ~= "string") or (e.cmd and type(e.cmd) ~= "string") then
        return "keys/cmd must be a string"
    end
    if e.steps and (not is_pairs(e.steps) or #e.steps == 0) then
        return "steps must be a list of { keys, explanation } pairs"
    end
    local at = e.at
    if type(at) == "string" then
        at = { at }
    end
    if type(at) ~= "table" or #at == 0 then
        return "needs at (a path or a list of paths)"
    end
    for _, p in ipairs(at) do
        if type(p) ~= "string" or p == "" then
            return "at contains an invalid path"
        end
    end
    if type(e.label) ~= "string" and type(e.desc) ~= "string" then
        return "needs a label or desc"
    end
    if e.parts ~= nil and not is_pairs(e.parts) then
        return "parts must be a list of { keys, meaning } pairs"
    end
    if e.also ~= nil and type(e.also) ~= "table" then
        return "also must be a list"
    end
    return nil
end

local function validate_node(n)
    if type(n) ~= "table" or type(n.path) ~= "string" or n.path == "" then
        return "needs a path"
    end
    return nil
end

--- Build a fresh tree. Returns { root = node, problems = { string }, packs = { name } }.
function M.build(user)
    user = user or require("howto").opts
    local nodes, seq, problems, packs = {}, 0, {}, {}
    local root = { path = "", label = "Howto", children = {}, entries = {}, seq = 0 }
    nodes[""] = root

    local function ensure(path)
        if nodes[path] then
            return nodes[path]
        end
        local parent = ensure(parent_of(path))
        seq = seq + 1
        local n = { path = path, label = last_segment(path), children = {}, entries = {}, seq = seq }
        nodes[path] = n
        table.insert(parent.children, n)
        return n
    end

    local function add_node(n, source)
        local err = validate_node(n)
        if err then
            table.insert(problems, ("[%s] node %s: %s"):format(source, vim.inspect(describe(n)), err))
            return
        end
        if not supported(n) then
            return
        end
        local node = ensure(n.path)
        for _, k in ipairs({ "label", "letter", "order", "desc" }) do
            if n[k] ~= nil then
                node[k] = n[k]
            end
        end
    end

    local function add_entry(e, source, extra)
        local err = validate_entry(e)
        if err then
            table.insert(problems, ("[%s] entry %s: %s"):format(source, vim.inspect(describe(type(e) == "table" and e or {})), err))
            return
        end
        if not supported(e) then
            return
        end
        local entry = vim.deepcopy(e)
        entry.source = source
        entry.kind = e.keys and "keys" or e.cmd and "cmd" or "steps"
        entry.label = e.label or e.desc
        local at = type(e.at) == "table" and vim.deepcopy(e.at) or { e.at }
        if extra then
            table.insert(at, extra)
        end
        local seen = {}
        for _, p in ipairs(at) do
            if not seen[p] then
                seen[p] = true
                table.insert(ensure(p).entries, entry)
            end
        end
    end

    local function add_module(mod, source, extra)
        if type(mod) ~= "table" then
            table.insert(problems, ("[%s] did not return a table"):format(source))
            return
        end
        for _, n in ipairs(mod.nodes or {}) do
            add_node(n, source)
        end
        for _, e in ipairs(mod.entries or {}) do
            add_entry(e, source, extra)
        end
    end

    local function load_file(file)
        local chunk, err = loadfile(file)
        if not chunk then
            return nil, err
        end
        local ok, res = pcall(chunk)
        if not ok then
            return nil, res
        end
        return res
    end

    for _, n in ipairs(ROOT_NODES) do
        add_node(n, "howto")
    end

    -- One file per name: when howto is on the runtimepath twice (dev checkout + install),
    -- the first copy wins instead of every entry showing twice.
    local function unique(files)
        local seen, out = {}, {}
        for _, f in ipairs(files) do
            local name = vim.fs.basename(f)
            if not seen[name] then
                seen[name] = true
                table.insert(out, f)
            end
        end
        table.sort(out, function(x, y) return vim.fs.basename(x) < vim.fs.basename(y) end)
        return out
    end

    -- 1. Native content.
    local native = unique(vim.api.nvim_get_runtime_file("lua/howto/native/*.lua", true))
    for _, file in ipairs(native) do
        local mod, err = load_file(file)
        local name = vim.fn.fnamemodify(file, ":t:r")
        if err then
            table.insert(problems, ("[native/%s] failed to load: %s"):format(name, err))
        else
            add_module(mod, "native")
        end
    end

    -- 2. Packs, only for installed plugins (a runtimepath directory with that name).
    local installed = {}
    for _, p in ipairs(vim.api.nvim_list_runtime_paths()) do
        installed[vim.fs.basename(p)] = true
    end
    local pack_files = unique(vim.api.nvim_get_runtime_file("lua/howto/packs/*.lua", true))
    for _, file in ipairs(pack_files) do
        local name = vim.fn.fnamemodify(file, ":t:r")
        local mod, err = load_file(file)
        if err then
            table.insert(problems, ("[pack %s] failed to load: %s"):format(name, err))
        elseif type(mod) ~= "table" or not mod.plugin then
            table.insert(problems, ("[pack %s] needs a plugin field"):format(name))
        else
            local names = type(mod.plugin) == "table" and mod.plugin or { mod.plugin }
            local present = false
            for _, n in ipairs(names) do
                present = present or installed[n] == true
            end
            if present then
                local display = mod.name or names[1]
                table.insert(packs, display)
                add_node({ path = "plugins/" .. display, label = display }, display)
                add_module(mod, display, "plugins/" .. display)
            end
        end
    end

    -- 3. The user's setup().
    add_module({ nodes = user.nodes, entries = user.entries }, "mine", "mine")

    -- Prune empty subtrees, order children, build the item lists the UI shows.
    local function finish(node)
        local kept = {}
        for _, c in ipairs(node.children) do
            if finish(c) then
                table.insert(kept, c)
            end
        end
        table.sort(kept, function(a, b)
            local oa, ob = a.order or 500, b.order or 500
            if oa ~= ob then
                return oa < ob
            end
            return a.seq < b.seq
        end)
        node.children = kept
        node.items = {}
        for _, c in ipairs(kept) do
            table.insert(node.items, { node = c })
        end
        for _, e in ipairs(node.entries) do
            table.insert(node.items, { entry = e })
        end
        return #node.items > 0
    end
    finish(root)

    return { root = root, problems = problems, packs = packs, nodes = nodes }
end

local cache

--- Forget the built tree; the next get() rebuilds it (used by setup()).
function M.reset()
    cache = nil
end

--- The tree for this session (built on first call).
function M.get()
    if not cache then
        cache = M.build()
    end
    return cache
end

--- Entries whose text contains every word of the query (case-insensitive).
function M.search(tree, query)
    local words = vim.split(query:lower(), "%s+", { trimempty = true })
    local out, seen = {}, {}
    local function text_of(e)
        local t = { e.keys or "", e.cmd or "", e.label or "", e.desc or "" }
        for _, p in ipairs(e.parts or {}) do
            table.insert(t, p[2])
        end
        for _, s in ipairs(e.steps or {}) do
            table.insert(t, s[1] .. " " .. s[2])
        end
        return table.concat(t, " "):lower()
    end
    local function walk(node)
        for _, e in ipairs(node.entries) do
            if not seen[e] then
                seen[e] = true
                local text = text_of(e)
                local all = #words > 0
                for _, w in ipairs(words) do
                    all = all and text:find(w, 1, true) ~= nil
                end
                if all then
                    table.insert(out, e)
                end
            end
        end
        for _, c in ipairs(node.children) do
            walk(c)
        end
    end
    walk(tree.root)
    return out
end

--- Paths for :Howto completion.
function M.paths(tree)
    local out = {}
    for path, node in pairs(tree.nodes) do
        if path ~= "" and node.items and #node.items > 0 then
            table.insert(out, path)
        end
    end
    table.sort(out)
    return out
end

return M
