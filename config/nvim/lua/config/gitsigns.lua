local gitsigns = require('gitsigns')

gitsigns.setup({
  on_attach = function(bufnr)
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      _G.vim.keymap.set(mode, l, r, opts)
    end

    map('n', '<leader>gs', gitsigns.stage_hunk)
    map('n', '<leader>gu', gitsigns.undo_stage_hunk)
    map('n', '<leader>gr', gitsigns.reset_hunk)
    map('n', '<leader>gR', gitsigns.reset_buffer)
    map('n', '<leader>gp', gitsigns.preview_hunk)
    map('n', '<leader>gp', function()
      gitsigns.blame_line({ full = true })
    end)
  end,
})
