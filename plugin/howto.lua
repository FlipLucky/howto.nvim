if vim.g.loaded_howto then
    return
end
vim.g.loaded_howto = true

vim.api.nvim_create_user_command("Howto", function(args)
    require("howto").open(args.args ~= "" and args.args or nil)
end, {
    nargs = "?",
    desc = "Find keys, commands and recipes by intent",
    complete = function(lead)
        local reg = require("howto.registry")
        return vim.tbl_filter(function(p) return vim.startswith(p, lead) end, reg.paths(reg.get()))
    end,
})
