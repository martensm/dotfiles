" Statusline
" ---

let g:lightline = {
    \ 'colorscheme': 'solarized',
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'gitbranch', 'readonly', 'modified' ] ]
    \ },
    \ 'component_function': {
    \   'fileencoding': 'LightlineFileencoding',
    \   'fileformat': 'LightlineFileformat',
    \   'filename': 'LightlineFilename',
    \   'filetype': 'LightlineFiletype',
    \   'gitbranch': 'LightlineGitbranch',
    \   'lineinfo': 'LightlineLineinfo',
    \   'readonly': 'LightlineReadonly',
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': '', 'right': '' }
  \ }

function! LightlineFileencoding()
  return winwidth(0) > 70 ? &fileencoding : ''
endfunction

function! LightlineFileformat()
  return winwidth(0) > 65 ? &fileformat : ''
endfunction

function! LightlineFilename()
  let name = expand('%:t')
  let filename = name !=# '' ? name : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction

function! LightlineFiletype()
  return winwidth(0) > 60 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineGitbranch()
  let symbol = winwidth(0) > 45 ? ' ' : ''
  let branch = gitbranch#name()
  return branch !=# '' ? symbol . branch : ''
endfunction

function! LightlineLineinfo()
  return printf("%3d:%-2d", line('.'), col('.'))
endfunction

function! LightlineReadonly()
  return &readonly && &filetype !=# 'help' ? '' : ''
endfunction
