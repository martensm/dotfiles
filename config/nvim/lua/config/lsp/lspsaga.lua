local utils = require('utils')

require('lspsaga').init_lsp_saga()

utils.nmap('gr', "<cmd>lua require('lspsaga.rename').rename()<CR>")
utils.nmap('gx', "<cmd>lua require('lspsaga.codeaction').code_action()<CR>")
utils.xmap('gx', "<cmd>lua require('lspsaga.codeaction').range_code_action()<CR>")
utils.nmap('K', "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>")
utils.nmap('gj', "lua require('lspsaga.diagnostic').jump_diagnostic_next()")
utils.nmap('gk', "lua require('lspsaga.diagnostic').jump_diagnostic_prev()")
utils.nmap('<C-d>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>")
utils.nmap('<C-u>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>")
