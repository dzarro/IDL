pro save2,p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,_extra=extra,exclude=exclude,routines=routines

if is_string(exclude) then begin
 for i=0,n_elements(exclude)-1 do begin
  prog=file_basename(exclude[i],'.pro')
  add_cmd,prog,'compile_opt NOSAVE',_extra=extra
 endfor
endif

routines=keyword_set(routines)
save_cmd='save,routines=routines,_extra=extra'
for i=0,n_params()-1 do begin
 arg='p'+strtrim(i,2)
 if routines then s=execute("defined=have_proc("+arg+",/init)") else s=execute("defined=n_elements(" + arg + ")" )
 if defined then save_cmd=save_cmd+','+arg
endfor

s=execute(save_cmd)

;mprint,save_cmd
return & end