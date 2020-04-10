version = '0.17.0'
package.path = os.getenv('XDG_CONFIG_HOME') .. '/xplr/plugins/?.lua'

require('fzf').setup({
  args = "--preview 'pistol {}'",
})
require('icons').setup()
require('ouch').setup()
require('trash-cli').setup()
require('xclip').setup()
require('zoxide').setup()
