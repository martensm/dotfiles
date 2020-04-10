local utils = require('utils')

require('telescope').setup({
  defaults = {
    prompt_prefix = ' ❯ ',
  },
})

utils.nmap('<Leader>ff', "<Cmd>lua require('telescope.builtin').find_files()<CR>")
utils.nmap('<Leader>fb', "<Cmd>lua require('telescope.builtin').buffers()<CR>")
utils.nmap(
  '<Leader>fc',
  "<Cmd>lua require('telescope.builtin').find_files({ follow = true, cwd = '$XDG_CONFIG_HOME' })<CR>"
)
utils.nmap('<Leader>fg', "<Cmd>lua require('telescope.builtin').live_grep()<CR>")
utils.nmap('<Leader>fh', "<Cmd>lua require('telescope.builtin').help_tags()<CR>")
