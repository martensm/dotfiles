local utils = require('utils')

require('nvim-tree').setup()

utils.nmap('<leader>t', ':NvimTreeToggle<CR>')
utils.nmap('<leader>tr', ':NvimTreeRefresh<CR>')
utils.nmap('<leader>tf', ':NvimTreeFindFile<CR>')
