pro undecorate,program,verbose=verbose

verbose=keyword_set(verbose)
p1=ptype(program,verbose=verbose)
if (p1 eq 0) then return

pro_name=file_basename(program,'.pro')
resolve_routine,pro_name,/either,/compile_full_file,quiet=~verbose

return & end