local utils = require('utils')

local format_disabled_var = function()
  return string.format('format_disabled_%s', vim.bo.filetype)
end

local M = {}

M.formatToggle = function(value)
  local var = format_disabled_var()
  vim.g[var] = utils._if(value ~= nil, value, not vim.g[var])
end

M.format = function()
  if not vim.g[format_disabled_var()] then
    vim.lsp.buf.formatting_sync({})
  end
end

return M
