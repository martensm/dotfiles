" Set custom augroup
augroup user_events
  autocmd!
augroup END

" Enables 24-bit RGB color in the terminal
set termguicolors

" Disable nvim distribution plugins
let g:loaded_2html_plugin = 1
let g:loaded_matchit = 1
let g:loaded_matchparen = 1
let g:loaded_netrwPlugin = 1
let g:loaded_tutor_mode_plugin = 1

" Set main configuration directory as parent directory
let $VIM_PATH =
  \ get(g:, 'etc_vim_path',
  \   exists('*stdpath') ? stdpath('config') :
  \   ! empty($MYVIMRC) ? fnamemodify(expand($MYVIMRC, 1), ':h') :
  \   ! empty($VIMCONFIG) ? expand($VIMCONFIG, 1) :
  \   ! empty($VIM_PATH) ? expand($VIM_PATH, 1) :
  \   fnamemodify(resolve(expand('<sfile>:p')), ':h:h')
  \ )

" Set data/cache directory as $XDG_CACHE_HOME/nvim
let $DATA_PATH = expand($XDG_CACHE_HOME . '/nvim', 1)

" Collection of user plugin list config file-paths
let s:config_paths = get(g:, 'etc_config_paths', [
	\ $VIM_PATH . '/config/plugins.yaml',
	\ $VIM_PATH . '/config/local.plugins.yaml',
	\ ])

call filter(s:config_paths, 'filereadable(v:val)')

function! s:main()
  if has('vim_starting')
    " When using VIMINIT trick for exotic MYVIMRC locations, add path now.
    if &runtimepath !~# $VIM_PATH
      set runtimepath^=$VIM_PATH
      set runtimepath+=$VIM_PATH/after
    endif

    " Ensure data directories
    for s:path in [
        \ $DATA_PATH,
        \ $DATA_PATH . '/undo',
        \ $DATA_PATH . '/backup',
        \ $DATA_PATH . '/session',
        \ $DATA_PATH . '/swap',
        \ $VIM_PATH . '/spell' ]
      if ! isdirectory(s:path)
        call mkdir(s:path, 'p')
      endif
    endfor

    let l:virtualenv = $DATA_PATH . '/venv/bin/python'
    if filereadable(l:virtualenv)
      let g:python3_host_prog = l:virtualenv
    endif
  endif

  call s:load_dein()
endfunction

function! s:load_dein()
  let l:cache_path = $DATA_PATH . '/dein'

  if has('vim_starting')
    " Use dein as a plugin manager
    let g:dein#auto_recache = 1
    let g:dein#install_max_processes = 12

    " Add dein to vim's runtimepath
    if &runtimepath !~# '/dein.vim'
      let s:dein_dir = l:cache_path . '/repos/github.com/Shougo/dein.vim'
      " Clone dein if first-time setup
      if ! isdirectory(s:dein_dir)
        execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir
        if v:shell_error
          call s:error('dein installation has failed! is git installed?')
          finish
        endif
      endif

      execute 'set runtimepath+='.substitute(
        \ fnamemodify(s:dein_dir, ':p') , '/$', '', '')
    endif
  endif

  " Initialize dein.vim
  if dein#load_state(l:cache_path)
    let l:rc = s:parse_yaml_files()
    if empty(l:rc)
      call s:error('Empty plugin list')
      return
    endif

    " Start propagating file paths and plugin presets
    call dein#begin(l:cache_path, extend([expand('<sfile>')], s:config_paths))
    for plugin in l:rc
      call dein#add(plugin['repo'], extend(plugin, {}, 'keep'))
    endfor

    " Add any local ./dev plugins
    if isdirectory($VIM_PATH . '/dev')
      call dein#local($VIM_PATH . '/dev', { 'frozen': 1, 'merged': 0 })
    endif
    call dein#end()

    " Save cached state for faster startups
    if ! g:dein#_is_sudo
      call dein#save_state()
    endif

    " Update or install plugins if a change detected
    if dein#check_install()
      call dein#install()
    endif
  endif

  filetype plugin indent on

  " Only enable syntax when vim is starting
  if has('vim_starting')
    syntax enable
  endif

  " Trigger source event hooks
  call dein#call_hook('source')
  call dein#call_hook('post_source')
endfunction

function! s:parse_yaml_files()
  let l:merged = []
  try
    " Merge all lists of plugins together
    for l:cfg_file in s:config_paths
      let l:merged = extend(l:merged, s:load_yaml(l:cfg_file))
    endfor
  catch /.*/
    call s:error(
      \ 'Unable to read configuration files at ' . string(s:config_paths))
    echoerr v:exception
  endtry

  " If there's more than one config file source,
  " de-duplicate plugins by repo key.
  if len(s:config_paths) > 1
    call s:dedupe_plugins(l:merged)
  endif
  return l:merged
endfunction

function! s:dedupe_plugins(list)
  let l:list = reverse(a:list)
  let l:i = 0
  let l:seen = {}
  while i < len(l:list)
    let l:key = list[i]['repo']
    if l:key !=# '' && has_key(l:seen, l:key)
      call remove(l:list, i)
    else
      if l:key !=# ''
        let l:seen[l:key] = 1
      endif
      let l:i += 1
    endif
  endwhile
  return reverse(l:list)
endfunction

function! s:load_yaml(filename)
  if a:filename =~# '\.ya\?ml$'
    if has('python3') && s:test_python_yaml()
      let l:cmd = g:python3_host_prog . " -c 'import sys,yaml,json; y=yaml.safe_load(sys.stdin.read()); print(json.dumps(y))'"
    else
      call s:error([
			\ 'Unable to find a YAML parsing utility.',
			\ 'Please run: pip install --user PyYAML',
      \ ])
    end

    try
      let l:raw = readfile(a:filename)
      return json_decode(system(l:cmd, l:raw))
    catch /.*/
      call s:error([
        \ string(v:exception),
        \ 'Error loading ' . a:filename,
        \ 'Caught: ' . string(v:exception),
        \ ])
    endtry
  endif
  call s:error('Unknown config file format ' . a:filename)
  return ''
endfunction

function! s:test_python_yaml()
	call system(g:python3_host_prog . " -c 'import sys,yaml,json'")
	return v:shell_error == 0
endfunction

function! s:error(msg)
  for l:mes in s:str2list(a:msg)
    echohl WarningMsg | echomsg '[config/init] ' . l:mes | echohl None
  endfor
endfunction

function! s:str2list(expr)
	return type(a:expr) ==# v:t_list ? a:expr : split(a:expr, '\n')
endfunction


call s:main()
