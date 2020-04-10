local gl = require('galaxyline')
local gls = gl.section
local devicons = require('nvim-web-devicons')
local vcs = require('galaxyline.provider_vcs')
local condition = require('galaxyline.condition')

gl.short_line_list = { 'packer' }

local icons = {
  paste = '',
  git = '',
  added = '',
  removed = '',
  modified = '',
  locker = '',
  not_modifiable = '',
  pencil = '',
  line_number = '',
  gears = '',
  ok = '',
  error = '',
  warning = '',
  info = '',
  hint = '',
}

local colors = {
  bg0_h = '#1d2021',
  bg0 = '#282828',
  bg1 = '#3c3836',
  bg2 = '#504945',
  bg3 = '#665c54',
  bg4 = '#7c6f64',
  gray = '#928374',
  fg0 = '#fbf1c7',
  fg1 = '#ebdbb2',
  fg2 = '#d5c4a1',
  fg3 = '#bdae93',
  fg4 = '#a89984',
  bright_red = '#fb4934',
  bright_green = '#b8bb26',
  bright_yellow = '#fabd2f',
  bright_blue = '#83a598',
  bright_purple = '#d3869b',
  bright_aqua = '#8ec07c',
  bright_orange = '#fe8019',
  neutral_red = '#cc241d',
  neutral_green = '#98971a',
  neutral_yellow = '#d79921',
  neutral_blue = '#458588',
  neutral_purple = '#b16286',
  neutral_aqua = '#689d6a',
  neutral_orange = '#d65d0e',
  faded_red = '#9d0006',
  faded_green = '#79740e',
  faded_yellow = '#b57614',
  faded_blue = '#076678',
  faded_purple = '#8f3f71',
  faded_aqua = '#427b58',
  faded_orange = '#af3a03',
}

local mode_map = {
  ['n'] = { 'NORMAL', colors.fg3, colors.bg2 },
  ['i'] = { 'INSERT', colors.bright_blue, colors.faded_blue },
  ['R'] = { 'REPLACE', colors.bright_red, colors.faded_red },
  ['v'] = { 'VISUAL', colors.bright_orange, colors.faded_orange },
  ['V'] = { 'V-LINE', colors.bright_orange, colors.faded_orange },
  ['c'] = { 'COMMAND', colors.bright_yellow, colors.faded_yellow },
  ['s'] = { 'SELECT', colors.bright_orange, colors.faded_orange },
  ['S'] = { 'S-LINE', colors.bright_orange, colors.faded_orange },
  ['t'] = { 'TERMINAL', colors.bright_aqua, colors.faded_aqua },
  [''] = { 'V-BLOCK', colors.bright_orange, colors.faded_orange },
  [''] = { 'S-BLOCK', colors.bright_orange, colors.faded_orange },
  ['Rv'] = { 'VIRTUAL' },
  ['rm'] = { '--MORE' },
}

-- local mode_sign_map = {
--   ["n"] = {"", colors.fg3, colors.bg2},
--   ["i"] = {"", colors.bright_blue, colors.faded_blue},
--   ["R"] = {"", colors.bright_red, colors.faded_red},
--   ["v"] = {"", colors.bright_orange, colors.faded_orange},
--   ["V"] = {"", colors.bright_orange, colors.faded_orange},
--   ["c"] = {"ﲵ", colors.bright_yellow, colors.faded_yellow},
--   ["s"] = {"", colors.bright_orange, colors.faded_orange},
--   ["S"] = {"", colors.bright_orange, colors.faded_orange},
--   ["t"] = {"", colors.bright_aqua, colors.faded_aqua},
--   [""] = {"", colors.bright_orange, colors.faded_orange},
--   [""] = {"", colors.bright_orange, colors.faded_orange},
--   ["rm"] = {""}
-- }

local sep = {
  right_filled = '',
  left_filled = '',
  right = '',
  left = '',
}

local mode_hl = function()
  local mode = mode_map[_G.vim.fn.mode()]
  if mode == nil then
    mode = mode_map['v']
    return { 'V-BLOCK', mode[2], mode[3] }
  end
  return mode
end

local highlight = function(group, fg, bg, gui)
  local cmd = string.format('highlight %s guifg=%s guibg=%s', group, fg, bg)
  if gui ~= nil then
    cmd = cmd .. ' gui=' .. gui
  end
  _G.vim.cmd(cmd)
end

local buffer_not_empty = function()
  if _G.vim.fn.empty(_G.vim.fn.expand('%:t')) ~= 1 then
    return true
  end
  return false
end

local diagnostic_exists = function()
  return not _G.vim.tbl_isempty(_G.vim.lsp.buf_get_clients(0))
end

local diag = function(severity)
  local n = #_G.vim.diagnostic.get(0, { severity = severity })
  if n == 0 then
    return ''
  end
  local icon
  if severity == _G.vim.diagnostic.severity.WARN then
    icon = icons.warning
  elseif severity == _G.vim.diagnostic.severity.ERROR then
    icon = icons.error
  elseif severity == _G.vim.diagnostic.severity.INFO then
    icon = icons.info
  elseif severity == _G.vim.diagnostic.severity.HINT then
    icon = icons.hint
  end
  return string.format(' %s %d ', icon, n)
end

local wide_enough = function(width)
  if _G.vim.fn.winwidth(0) > width then
    return true
  end
  return false
end

local in_vcs = function()
  if _G.vim.bo.buftype == 'help' then
    return false
  end
  return condition.check_git_workspace()
end

gls.left[1] = {
  ViMode = {
    provider = function()
      local label, fg, nested_fg = _G.unpack(mode_hl())
      highlight('GalaxyViMode', nested_fg, fg)
      highlight('GalaxyViModeInv', fg, nested_fg)
      highlight('GalaxyViModeNested', fg, nested_fg)
      highlight('GalaxyViModeInvNested', nested_fg, colors.bg1)
      local mode = '  ' .. label .. ' '
      if _G.vim.o.paste then
        mode = mode .. sep.left .. ' ' .. icons.paste .. ' Paste '
      end
      return mode
    end,
    separator = sep.left_filled,
    separator_highlight = 'GalaxyViModeInv',
  },
}
gls.left[2] = {
  FileIcon = {
    provider = function()
      local extension = _G.vim.fn.expand('%:e')
      local icon, iconhl = devicons.get_icon(extension)
      if icon == nil then
        return ''
      end

      local fg = _G.vim.fn.synIDattr(_G.vim.fn.hlID(iconhl), 'fg')
      local _, _, bg = _G.unpack(mode_hl())
      highlight('GalaxyFileIcon', fg, bg)

      return ' ' .. icon .. ' '
    end,
    condition = buffer_not_empty,
  },
}
gls.left[3] = {
  FileName = {
    provider = function()
      if _G.vim.bo.buftype == 'terminal' then
        return ''
      end
      if not buffer_not_empty() then
        return ''
      end

      local fname
      if wide_enough(120) then
        fname = _G.vim.fn.fnamemodify(_G.vim.fn.expand('%'), ':~:.')
        if #fname > 35 then
          fname = _G.vim.fn.expand('%:t')
        end
      else
        fname = _G.vim.fn.expand('%:t')
      end
      if #fname == 0 then
        return ''
      end

      if _G.vim.bo.readonly then
        fname = fname .. ' ' .. icons.locker
      end
      if not _G.vim.bo.modifiable then
        fname = fname .. ' ' .. icons.not_modifiable
      end
      if _G.vim.bo.modified then
        fname = fname .. ' ' .. icons.pencil
      end

      return ' ' .. fname .. ' '
    end,
    highlight = 'GalaxyViModeNested',
    condition = buffer_not_empty,
  },
}
gls.left[4] = {
  LeftSep = {
    provider = function()
      return sep.left_filled
    end,
    highlight = 'GalaxyViModeInvNested',
  },
}
gls.left[5] = {
  GitIcon = {
    provider = function()
      highlight('DiffAdd', colors.bright_green, colors.bg1)
      highlight('DiffChange', colors.bright_orange, colors.bg1)
      highlight('DiffDelete', colors.bright_red, colors.bg1)
      if in_vcs() and wide_enough(85) then
        return '  ' .. icons.git .. ' '
      end
      return ''
    end,
    highlight = { colors.bright_red, colors.bg1 },
  },
}
gls.left[6] = {
  GitBranch = {
    provider = function()
      local git_branch = vcs.get_git_branch()
      if in_vcs() and git_branch and wide_enough(85) then
        return git_branch .. ' '
      end
      return ''
    end,
    highlight = { colors.fg2, colors.bg1 },
  },
}
gls.left[7] = {
  DiffAdd = {
    provider = function()
      if condition.check_git_workspace() and wide_enough(100) then
        return vcs.diff_add()
      end
      return ''
    end,
    icon = icons.added .. ' ',
    highlight = { colors.bright_green, colors.bg1 },
  },
}
gls.left[8] = {
  DiffModified = {
    provider = function()
      if condition.check_git_workspace() and wide_enough(100) then
        return vcs.diff_modified()
      end
      return ''
    end,
    icon = icons.modified .. ' ',
    highlight = { colors.bright_orange, colors.bg1 },
  },
}
gls.left[9] = {
  DiffRemove = {
    provider = function()
      if condition.check_git_workspace() and wide_enough(100) then
        return vcs.diff_remove()
      end
      return ''
    end,
    icon = icons.removed .. ' ',
    highlight = { colors.bright_red, colors.bg1 },
  },
}

gls.right[1] = {
  DiagnosticOk = {
    provider = function()
      if not diagnostic_exists() then
        return ''
      end
      local w = #_G.vim.diagnostic.get(0, { severity = _G.vim.diagnostic.severity.WARN })
      local e = #_G.vim.diagnostic.get(0, { severity = _G.vim.diagnostic.severity.ERROR })
      local i = #_G.vim.diagnostic.get(0, { severity = _G.vim.diagnostic.severity.INFO })
      local h = #_G.vim.diagnostic.get(0, { severity = _G.vim.diagnostic.severity.HINT })
      if w ~= 0 or e ~= 0 or i ~= 0 or h ~= 0 then
        return ''
      end
      return icons.ok .. ' '
    end,
    highlight = { colors.bright_green, colors.bg1 },
  },
}
gls.right[2] = {
  DiagnosticError = {
    provider = function()
      return diag(_G.vim.diagnostic.severity.ERROR)
    end,
    highlight = { colors.bright_red, colors.bg1 },
  },
}
gls.right[3] = {
  DiagnosticWarn = {
    provider = function()
      return diag(_G.vim.diagnostic.severity.WARN)
    end,
    highlight = { colors.bright_yellow, colors.bg1 },
  },
}
gls.right[4] = {
  DiagnosticInfo = {
    provider = function()
      return diag(_G.vim.diagnostic.severity.INFO)
    end,
    highlight = { colors.bright_blue, colors.bg1 },
  },
}
gls.right[5] = {
  DiagnosticHint = {
    provider = function()
      return diag(_G.vim.diagnostic.severity.HINT)
    end,
    highlight = { colors.bright_aqua, colors.bg1 },
  },
}
gls.right[6] = {
  RightSepNested = {
    provider = function()
      return sep.right_filled
    end,
    highlight = 'GalaxyViModeInvNested',
  },
}
gls.right[7] = {
  FileFormat = {
    provider = function()
      if not buffer_not_empty() or not wide_enough(70) then
        return ''
      end
      local icon = icons[_G.vim.bo.fileformat] or ''
      return string.format('  %s %s ', icon, _G.vim.bo.fileencoding)
    end,
    highlight = 'GalaxyViModeNested',
  },
}
gls.right[8] = {
  RightSep = {
    provider = function()
      return sep.right_filled
    end,
    highlight = 'GalaxyViModeInv',
  },
}
gls.right[9] = {
  PositionInfo = {
    provider = function()
      if not buffer_not_empty() or not wide_enough(60) then
        return ''
      end
      return string.format('  %s %s:%s ', icons.line_number, _G.vim.fn.line('.'), _G.vim.fn.col('.'))
    end,
    highlight = 'GalaxyViMode',
  },
}

local short_map = { ['packer'] = 'Packer' }

local has_file_type = function()
  local f_type = _G.vim.bo.filetype
  if not f_type or f_type == '' then
    return false
  end
  return true
end

gls.short_line_left[1] = {
  BufferType = {
    provider = function()
      local _, fg, nested_fg = _G.unpack(mode_hl())
      highlight('GalaxyViMode', nested_fg, fg)
      highlight('GalaxyViModeInv', fg, nested_fg)
      highlight('GalaxyViModeInvNested', nested_fg, colors.bg1)
      local name = short_map[_G.vim.bo.filetype] or 'Editor'
      return string.format('  %s ', name)
    end,
    highlight = 'GalaxyViMode',
    condition = has_file_type,
    separator = sep.left_filled,
    separator_highlight = 'GalaxyViModeInv',
  },
}
gls.short_line_left[2] = {
  ShortLeftSepNested = {
    provider = function()
      return sep.left_filled
    end,
    highlight = 'GalaxyViModeInvNested',
  },
}
gls.short_line_right[1] = {
  ShortRightSepNested = {
    provider = function()
      return sep.right_filled
    end,
    highlight = 'GalaxyViModeInvNested',
  },
}
gls.short_line_right[2] = {
  ShortRightSep = {
    provider = function()
      return sep.right_filled
    end,
    highlight = 'GalaxyViModeInv',
  },
}
