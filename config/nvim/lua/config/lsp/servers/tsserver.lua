local ts_utils = require('nvim-lsp-ts-utils')

local M = {}

M.get_config = function(on_attach)
  return {
    init_options = ts_utils.init_options,
    on_attach = function(client, ...)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false

      ts_utils.setup({
        enable_import_on_completion = true,
        update_imports_on_move = true,
      })
      ts_utils.setup_client(client)

      if type(on_attach) == 'function' then
        on_attach(client, ...)
      end
    end,
  }
end

return M
