local utils = require('mp.utils')
local msg = require('mp.msg')

local append

local handleres = function(res, args, primary)
  if not res.error and res.status == 0 then
    return res.stdout
  end

  if not primary then
    append(true)
    return nil
  end
  msg.error('There was an error getting linux clipboard: ')
  msg.error('  Status: ' .. (res.status or ''))
  msg.error('  Error: ' .. (res.error or ''))
  msg.error('  stdout: ' .. (res.stdout or ''))
  msg.error('args: ' .. utils.to_string(args))
  return nil
end

local get_clipboard = function(primary)
  local args = {
    'xclip',
    '-selection',
    primary and 'primary' or 'clipboard',
    '-out',
  }
  return handleres(utils.subprocess({ args = args }), args, primary)
end

append = function(primaryselect)
  local clipboard = get_clipboard(primaryselect or false)
  if clipboard then
    mp.commandv('loadfile', clipboard, 'append-play')
    mp.osd_message('URL appended: ' .. clipboard)
    msg.info('URL appended: ' .. clipboard)
  end
end

mp.add_key_binding('ctrl+v', 'appendURL', append)
