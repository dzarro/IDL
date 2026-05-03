
pro add_cmd,proc,cmd,err=err,verbose=verbose

verbose=keyword_set(verbose)

if is_blank(proc) || is_blank(cmd) then begin
 err='Missing input program name or command to add.'
 mprint,err
 return
endif

sname=file_basename(proc,'.pro')
chk=have_proc(sname,out=sfile,/init)
if ~chk then begin
 mprint,'Input program not found - '+proc
 return
endif

;-- skip if proc in SCOPE_TRACEBACK chain

chain=scope_traceback(/structure)
chk=where(strlowcase(proc) eq strlowcase(chain.routine),count)
if count gt 0 then begin
 mprint,'Skipping - '+proc
 return
endif

if verbose then mprint,'Reading from '+sfile,/cont
temp=strtrim(rd_ascii(sfile))

;-- find first occurrence of pro or function call

chk=where(stregex(temp, '^(pro +|function +)',/bool),count)
if count eq 0 then begin
 err='Input program not a valid procedure or function.'
 mprint,err
 return
endif
temp=temp[chk[0]: n_elements(temp)-1]

;-- find first line after pro/function call and insert command there

np=n_elements(temp)
for i=0,np-1 do begin
 chk=~stregex(temp[i],'\$$',/bool)
 if chk then break
endfor

if (i eq (np-1)) && ~chk then begin
 err='Improperly defined program - '+proc
 mprint,err
 return
endif

;-- trap errors

cdir=curdir()
error=0
catch,error
if (error ne 0)  then begin ;|| (!error_state.code ne 0) then begin
 err=err_state()
 mprint,err
 catch,/cancel
 message,/reset
 error=0
 cd,cdir
 mprint,'Bailing.'
 return
endif

top=i
front=temp[0:top]
bottom=(top+1) < (np-1)
back=temp[bottom:np-1]
temp=[front,cmd,back]

;-- now compile program with added command

out_file=get_temp_file('test.pro')
pro_dir=file_dirname(out_file)
pro_name=file_basename(out_file,'.pro')
out=[temp,' ','pro '+pro_name,'compile_opt NOSAVE','return & end']
if verbose then mprint,'Writing to '+out_file
wrt_ascii,out,out_file,/no_pad
cd,pro_dir
resolve_routine,pro_name,/either,/compile_full_file,quiet=1-verbose
cd,cdir
;file_delete,out_file,/quiet
return 
end
