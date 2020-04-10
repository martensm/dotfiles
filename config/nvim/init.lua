local set_keymap = vim.api.nvim_set_keymap
local g = vim.g

local disable_distribution_plugins = function()
  g.loaded_gzip = 1
  g.loaded_tar = 1
  g.loaded_tarPlugin = 1
  g.loaded_zip = 1
  g.loaded_zipPlugin = 1
  g.loaded_getscript = 1
  g.loaded_getscriptPlugin = 1
  g.loaded_vimball = 1
  g.loaded_vimballPlugin = 1
  g.loaded_matchit = 1
  g.loaded_matchparen = 1
  g.loaded_2html_plugin = 1
  g.loaded_logiPat = 1
  g.loaded_rrhelper = 1
  g.loaded_netrw = 1
  g.loaded_netrwPlugin = 1
  g.loaded_netrwSettings = 1
  g.loaded_netrwFileHandlers = 1
end

local leader_map = function()
  g.mapleader = ' '
  set_keymap('n', ' ', '', { noremap = true })
  set_keymap('x', ' ', '', { noremap = true })
end

disable_distribution_plugins()
leader_map()

require('options')
require('plugins')
