filetypes = require("tree-sitter-manager.filetypes")

for lang, ft in pairs(filetypes) do
    vim.treesitter.language.register(lang, ft)
end

-- Extensions that Neovim does not detect natively.
-- .uc and .ucode hold both ucode scripts and ucode_markup templates: a file
-- is a template when a line starts with a tag opener ({%, {{, {#).
local function ucode_or_markup(_, bufnr)
    for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
        if line:match("^%s*{[%%{#]") then
            return "ucode_markup"
        end
    end
    return "ucode"
end

vim.filetype.add({
    extension = {
        uc = ucode_or_markup,
        ucode = ucode_or_markup,
        ut = "ucode_markup",
        utpl = "ucode_markup",
    },
    pattern = {
        -- An extensionless script whose #! line names ucode.
        [".*"] = {
            function(_, bufnr)
                local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""
                if first:match("^#!.*%f[%w]ucode%f[%W]") then
                    return "ucode"
                end
            end,
            { priority = -math.huge },
        },
    },
})
