vim.cmd('packadd packer.nvim')

local present, packer = pcall(require, 'packer')

if not present then
  local packer_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
  local repo = 'https://github.com/wbthomason/packer.nvim'

  print('Cloning packer...')
  -- remove the dir before cloning
  vim.fn.delete(packer_path, 'rf')
  vim.fn.system({ 'git', 'clone', repo, '--depth', '20', packer_path })

  vim.cmd('packadd packer.nvim')
  present, packer = pcall(require, 'packer')

  if present then
    print('Packer cloned successfully.')
  else
    error(("Couldn't clone packer!\nPacker path: %s\n%s"):format(packer_path, packer))
  end
end

return packer.startup({
  function(use)
    use({ 'wbthomason/packer.nvim', opt = true })

    use({
      'jose-elias-alvarez/null-ls.nvim',
      requires = {
        { 'neovim/nvim-lspconfig' },
        { 'nvim-lua/plenary.nvim' },
      },
    })
    use('RRethy/vim-illuminate')
    use('b0o/schemastore.nvim')
    use('jose-elias-alvarez/nvim-lsp-ts-utils')
    use({
      'williamboman/nvim-lsp-installer',
      after = {
        'schemastore.nvim',
        'nvim-lsp-ts-utils',
        'null-ls.nvim',
        'vim-illuminate',
      },
      config = function()
        require('config.lsp')
      end,
      requires = 'neovim/nvim-lspconfig',
    })
    use({
      'tami5/lspsaga.nvim',
      config = function()
        require('config.lsp.lspsaga')
      end,
      requires = 'neovim/nvim-lspconfig',
    })
    use({
      'hrsh7th/nvim-cmp',
      config = function()
        require('config.cmp')
      end,
      requires = {
        { 'neovim/nvim-lspconfig' },
        { 'hrsh7th/cmp-buffer' },
        { 'hrsh7th/cmp-calc' },
        { 'hrsh7th/cmp-cmdline' },
        { 'hrsh7th/cmp-nvim-lsp' },
        { 'hrsh7th/cmp-nvim-lua' },
        { 'hrsh7th/cmp-path' },
        { 'L3MON4D3/LuaSnip' },
        { 'onsails/lspkind-nvim' },
        { 'rafamadriz/friendly-snippets' },
        { 'saadparwaiz1/cmp_luasnip' },
      },
    })
    use({
      'nvim-treesitter/nvim-treesitter',
      config = function()
        require('config.treesitter')
      end,
      run = ':TSUpdate',
      requires = 'p00f/nvim-ts-rainbow',
    })
    use({
      'kyazdani42/nvim-web-devicons',
      config = function()
        require('config.devicons')
      end,
    })
    use({
      'glepnir/dashboard-nvim',
      config = function()
        require('config.dashboard')
      end,
      event = 'BufWinEnter',
    })
    use({
      'nvim-telescope/telescope.nvim',
      after = 'nvim-web-devicons',
      cmd = 'Telescope',
      config = function()
        require('config.telescope')
      end,
      keys = '<Leader>f',
      module = 'telescope',
      requires = {
        { 'nvim-lua/plenary.nvim' },
      },
    })
    use('dstein64/nvim-scrollview')
    use({
      'romgrk/barbar.nvim',
      after = 'nvim-web-devicons',
      event = 'BufWinEnter',
    })
    use('editorconfig/editorconfig-vim')
    use({
      'kyazdani42/nvim-tree.lua',
      after = 'nvim-web-devicons',
      cmd = { 'NvimTreeToggle', 'NvimTreeRefresh', 'NvimTreeFindFile' },
      config = function()
        require('config.tree')
      end,
      keys = '<Leader>t',
    })
    use({
      'folke/trouble.nvim',
      after = 'nvim-web-devicons',
      config = function()
        require('config.trouble')
      end,
    })
    use({
      'folke/which-key.nvim',
      config = function()
        require('config.which-key')
      end,
      event = 'BufWinEnter',
    })
    use({
      'windwp/nvim-autopairs',
      config = function()
        require('config.autopairs')
      end,
    })
    use('christoomey/vim-tmux-navigator')
    use({
      'npxbr/gruvbox.nvim',
      config = function()
        require('config.gruvbox')
      end,
      requires = 'rktjmp/lush.nvim',
    })
    use({
      'glepnir/galaxyline.nvim',
      config = function()
        require('config.galaxyline')
      end,
      requires = { 'kyazdani42/nvim-web-devicons', opt = 'true' },
    })
    use({
      'lukas-reineke/indent-blankline.nvim',
      config = function()
        require('config.indent-blankline')
      end,
      event = 'BufRead',
      requires = 'nvim-treesitter/nvim-treesitter',
    })
    use({
      'lewis6991/gitsigns.nvim',
      config = function()
        require('config.gitsigns')
      end,
      event = 'BufRead',
      requires = 'nvim-lua/plenary.nvim',
    })
    use({
      'norcalli/nvim-colorizer.lua',
      config = function()
        require('config.colorizer')
      end,
      event = 'BufRead',
      ft = { 'css', 'javascript', 'typescript', 'vue' },
    })
    use({
      'terrortylor/nvim-comment',
      cmd = 'CommentToggle',
      config = function()
        require('config.nvim-comment')
      end,
      keys = '<Leader>c',
    })
    use({
      'Saecki/crates.nvim',
      config = function()
        require('config.crates')
      end,
      event = { 'BufRead Cargo.toml' },
      requires = 'nvim-lua/plenary.nvim',
    })
  end,
  config = {
    display = {
      open_fn = function()
        return require('packer.util').float({ border = 'none' })
      end,
    },
  },
})
