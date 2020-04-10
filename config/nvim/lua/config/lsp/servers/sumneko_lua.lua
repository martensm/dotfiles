local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

local M = {}

M.get_config = function(on_attach)
  return {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT', path = runtime_path },
        completion = { keywordSnippet = 'Disable' },
        diagnostics = {
          enable = true,
          globals = {
            'after_each',
            'before_each',
            'describe',
            'it',
            'vim',
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file('', true),
          },
        },
      },
    },
    on_attach = on_attach,
  }
end

return M
