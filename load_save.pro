pro load_save,verbose=verbose

compile_opt NOSAVE

;-- locate and verify load_save.sav file

which,'load_save',/quiet,out=out
odir=file_dirname(out[0])
sfile=concat_dir(odir,'load_save.sav')
if ~file_test(sfile,/reg) then return 
startup=local_name('$SSW/site/setup/IDL_STARTUP.pro')
if ~file_test(startup,/reg) then file_create,startup

;-- read IDL Site Startup file and remove any duplicate restore load_save commands

lines=rd_tfile(startup)
nlines=n_elements(lines)
look=stregex(lines,'restore,"'+'(.+)'+'.+',/sub,/extract)
chk=where(strtrim(look[1,*],2) ne '',count,ncomplement=ncomp,complement=complement)
if ncomp gt 0 then new_lines=lines[complement] else new_lines=''

;-- delete any old load_save files in directories that don't match directory of current load_save file

if count gt 0 then begin
 file=get_uniq(comdim2(look[1,chk]))
 fdir=file_dirname(file)
 chk2=where( (fdir eq '.') or (fdir eq ''),count2)
 if count2 gt 0 then fdir[chk2]=odir
 chk3=where(fdir ne odir,count3)
 if count3 gt 0 then file_delete,file[chk3],/allow_nonexistent,/verbose
endif

;-- append new restore load_save command line and execute it

new_line='restore,"'+sfile +'"' ;,/verbose'

lines=[new_lines,new_line]
if keyword_set(verbose) then mprint,'Executing: '+new_line

error=0
catch,error
if error ne 0 then begin
 err=err_state()
 mprint,err,/info
 catch,/cancel
 message,/reset
 error=0
 return
endif

restore,sfile,verbose=verbose

;-- update Site Startup file

wrt_ascii,lines,startup

return
end
