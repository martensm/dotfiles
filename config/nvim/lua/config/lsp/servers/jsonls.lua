local schemastore = require('schemastore')

local M = {}

M.setup = function(on_attach)
  return {
    settings = {
      json = {
        schemas = schemastore.json.schemas(),
      },
    },
    on_attach = on_attach,
  }
end

return M
