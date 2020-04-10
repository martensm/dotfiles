local null_ls = require('null-ls')
local b = null_ls.builtins

local M = {}

M.get_config = function(on_attach)
  return {
    sources = {
      b.code_actions.eslint_d,
      b.completion.spell,
      b.diagnostics.codespell,
      b.diagnostics.eslint_d,
      b.diagnostics.hadolint,
      b.diagnostics.markdownlint,
      b.diagnostics.pylint,
      b.diagnostics.selene,
      b.diagnostics.shellcheck,
      b.diagnostics.stylelint,
      b.diagnostics.yamllint,
      b.formatting.black,
      b.formatting.eslint_d,
      b.formatting.fixjson,
      b.formatting.isort,
      b.formatting.markdownlint,
      b.formatting.prettierd,
      b.formatting.rustfmt,
      b.formatting.rustywind,
      b.formatting.shfmt,
      b.formatting.stylelint,
      b.formatting.stylua,
      b.formatting.taplo,
    },
    on_attach = on_attach,
  }
end

return M
