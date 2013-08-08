function! s:ExecRspec()
  if exists('b:rails_root')
    exe '!rake spec SPEC="'.expand('%:p').'" SPEC_OPTS="-l '.line('.').' '.g:rails_rspec_opt.'"'
  else
    exe '!rspec -1 '.line('.').' '.g:rspec_opt.' %'
  endif
endfunction

if !exists('g:rspec_opt')
  let g:rspec_opt = '-fs -c'
end

if !exists('g:rails_rspec_opt')
  let g:rails_rspec_opt = g:rspec_opt
end

au BufRead,BufNewFile *_spec.rb command! Spec call s:ExecRspec()
