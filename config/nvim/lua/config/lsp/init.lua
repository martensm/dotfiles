local lspconfig = require('lspconfig')
local lsp_installer_servers = require('nvim-lsp-installer.servers')
local illuminate = require('illuminate')
local null_ls_config = require('config.lsp.servers.null-ls')
local utils = require('utils')

local required_servers = {
  'bashls',
  'cssls',
  'dockerls',
  'html',
  'jsonls',
  'pyright',
  'rust_analyzer',
  'sumneko_lua',
  'tailwindcss',
  'tsserver',
  'yamlls',
}

local on_attach = function(client, bufnr)
  if client.resolved_capabilities.document_formatting then
    vim.cmd([[autocmd BufWritePre <buffer> lua require('config.lsp.formatting').format()]])
  end

  illuminate.on_attach(client)
end

local config = null_ls_config.get_config(on_attach)
require('null-ls').setup(config)

for _, server in ipairs(required_servers) do
  local server_available, requested_server = lsp_installer_servers.get_server(server)

  if server_available then
    local _, server_config = pcall(require, 'config.lsp.servers.' .. server)

    requested_server:on_ready(function()
      local config = server_config and server_config.get_config and server_config.get_config(on_attach) or {}
      requested_server:setup(config)
    end)

    if not requested_server:is_installed() then
      requested_server:install()
    end
  end
end

utils.lua_command('FormatDisable', "require('config.lsp.formatting').formatToggle(true)")
utils.lua_command('FormatEnable', "require('config.lsp.formatting').formatToggle(false)")
