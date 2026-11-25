-- Integrity of the shipped content: a typo would put an entry in the wrong place or teach a wrong key.
local h = require("helpers")
local T = {}

local function shipped(kind)
    local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
    local out = {}
    for _, file in ipairs(vim.fn.glob(root .. "/lua/howto/" .. kind .. "/*.lua", false, true)) do
        out[vim.fn.fnamemodify(file, ":t:r")] = dofile(file)
    end
    return out
end

local function paths(entry)
    return type(entry.at) == "table" and entry.at or { entry.at }
end

T["every native entry hangs on a declared node"] = function()
    local declared = {}
    for _, mod in pairs(shipped("native")) do
        for _, n in ipairs(mod.nodes or {}) do
            declared[n.path] = true
        end
    end
    local bad = {}
    for name, mod in pairs(shipped("native")) do
        for _, e in ipairs(mod.entries or {}) do
            for _, p in ipairs(paths(e)) do
                if not declared[p] then
                    table.insert(bad, name .. ": " .. (e.keys or e.cmd or e.label) .. " → " .. tostring(p))
                end
            end
        end
    end
    assert(#bad == 0, "entries on undeclared paths (typo?):\n" .. table.concat(bad, "\n"))
end

T["every node's parent is declared"] = function()
    local declared = {}
    local all = {}
    for _, kind in ipairs({ "native" }) do
        for _, mod in pairs(shipped(kind)) do
            for _, n in ipairs(mod.nodes or {}) do
                declared[n.path] = true
                table.insert(all, n.path)
            end
        end
    end
    for _, p in ipairs(all) do
        local parent = p:match("^(.*)/[^/]+$")
        assert(not parent or declared[parent], "node " .. p .. " has no declared parent")
    end
end

T["key parts spell the keys in typed order"] = function()
    local bad = {}
    for kind, mods in pairs({ native = shipped("native"), packs = shipped("packs") }) do
        for name, mod in pairs(mods) do
            for _, e in ipairs(mod.entries or {}) do
                if e.keys and e.parts then
                    local s = table.concat(vim.tbl_map(function(p) return p[1] end, e.parts))
                    if s ~= e.keys then
                        table.insert(bad, ("%s/%s: %s ≠ %s"):format(kind, name, e.keys, s))
                    end
                end
            end
        end
    end
    assert(#bad == 0, "parts don't spell the keys:\n" .. table.concat(bad, "\n"))
end

T["no warnings from the shipped content"] = function()
    h.open()
    assert(#h.notes == 0, "shipped content produced warnings:\n" .. h.warnings())
end

T["every pack names its plugin"] = function()
    for name, mod in pairs(shipped("packs")) do
        assert(mod.plugin, "pack " .. name .. " has no plugin field")
    end
end

return T
