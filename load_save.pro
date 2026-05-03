pro load_save,verbose=verbose,update_site=update_site,download_save=download_save

;compile_opt NOSAVE

;-- locate, verify, and restore load_save.sav file

verbose=keyword_set(verbose)
if keyword_set(download_save) then sock_get,'https://raw.githubusercontent.com/dzarro/IDL/refs/heads/main/load_save.sav',verbose=verbose
out=routine_filepath('load_save')
odir=file_dirname(out[0])
if verbose then print,'Working directory - '+odir
sfile=concat_dir(odir,'load_save.sav')
if ~file_test(sfile) then begin
 mprint,'LOAD_SAVE file not found.'
 return 
endif

restore,sfile,verbose=verbose

error=0
catch,error
if (error ne 0) then begin
 err=err_state()
 mprint,err,/info
 catch,/cancel
 message,/reset
 error=0
 if verbose then mprint,'Continuing after CATCH.'
endif

if ~keyword_set(update_site) then return

;-- read IDL Site Startup file and remove any duplicate restore load_save commands

startup=local_name('$SSW/site/setup/IDL_STARTUP.pro')
if ~file_test(startup,/reg) then file_create,startup

lines=rd_tfile(startup)
nlines=n_elements(lines)
look=stregex(lines,'.*restore,"'+'(.+)'+'.+',/sub,/extract)
chk=where(strtrim(look[1,*],2) ne '',count,ncomplement=ncomp,complement=complement)
if ncomp gt 0 then new_lines=lines[complement] else new_lines=''

;-- delete any old load_save files in directories that don't match directory of current load_save file

if count gt 0 then begin
 file=get_uniq(comdim2(look[1,chk]))
 fdir=file_dirname(file)
 chk2=where( (fdir eq '.') or (fdir eq ''),count2)
 if count2 gt 0 then fdir[chk2]=odir
 chk3=where(fdir ne odir,count3)
 if count3 gt 0 then begin
  ;print,file[chk3]
  file_delete,file[chk3],/allow_nonexistent,verbose=verbose
 endif
endif

;-- append new restore load_save command line 

new_line='if file_test("'+sfile+'") then restore,"'+sfile +'"' ;,/verbose'
lines=[new_lines,new_line]

;-- update Site Startup file

wrt_ascii,lines,startup,/no_pad

return
end
