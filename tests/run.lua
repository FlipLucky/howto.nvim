-- Minimal test runner, no dependencies: `nvim -l tests/run.lua [filter]`.
-- Each tests/test_*.lua returns { ["name"] = function() ... end }.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)
package.path = root .. "/tests/?.lua;" .. package.path

local filter = arg[1]
local files = vim.fn.glob(root .. "/tests/test_*.lua", false, true)
table.sort(files)

local h = require("helpers")
local passed, failed = 0, {}
for _, file in ipairs(files) do
    local cases = dofile(file)
    local names = vim.tbl_keys(cases)
    table.sort(names)
    for _, name in ipairs(names) do
        local full = vim.fn.fnamemodify(file, ":t:r") .. " › " .. name
        if not filter or full:find(filter, 1, true) then
            h.reset()
            local ok, err = xpcall(cases[name], debug.traceback)
            if ok then
                passed = passed + 1
                io.stdout:write("  ok   " .. full .. "\n")
            else
                table.insert(failed, full)
                io.stdout:write("  FAIL " .. full .. "\n" .. tostring(err):gsub("\n", "\n       ") .. "\n")
            end
        end
    end
end
io.stdout:write(("\n%d passed, %d failed\n"):format(passed, #failed))
os.exit(#failed == 0 and 0 or 1)
