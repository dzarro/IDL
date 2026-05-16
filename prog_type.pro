;+
; Project     : SDAC
;                  
; Name        : PROG_TYPE
;               
; Purpose     : Determine whether a program is a function or procedure
;                             
; Category    : system utility 
;               
; Syntax      : IDL> ptype=prog_type(program)
;
; Inputs:     : PROGRAM = name of program to check
;              
; Outputs     : PTYPE = 1 if procedure; 2 if function; 0 otherwise
;
; Keywords    : SUB_PROG = name of procedure or function within program to check
;                         (optional if a sub program is embedded within program code)
;               CALL = string containing program calling arguments and keywords
;               PROG_FILE = program name with path 
;               INDEX = first line in PROG_FILE where CALL is located
;               VERBOSE = set for verbose output
;               ERR = error string
;                          
; History     : 12-May-2026, Zarro (Retired) - written
;               
; Contact     : dzarro@solar.stanford.edu
;-    

function prog_type,program,sub_prog=sub_prog,verbose=verbose,call=call,prog_file=prog_file,index=index,err=err,_extra=extra

err='' & call='' & index=-1 & prog_file=''

verbose=keyword_set(verbose)
if is_blank(program) then begin
 err='Program name not entered.'
 if verbose then mprint,err,_extra=extra
 return,0
endif

sname=file_basename(program,'.pro')
chk=have_proc(sname,out=prog_file,/init)
if ~chk then begin
 err='Program not found - '+sname
 if verbose then mprint,err,_extra=extra
 return,0
endif
 
 if keyword_set(verbose) then mprint,prog_file

;-- find first occurrence of pro or function call

temp=strtrim(rd_ascii(prog_file),2)
if is_string(sub_prog) then sname=sub_prog
sname=str_escape(sname)+' *,'
search='^((pro +('+sname+')+)|(function +('+sname+')+))'
chk=where(stregex(temp,search,/bool,/fold),count)
if verbose then mprint,search,_extra=extra

if count eq 0 then begin
 err='Program call not found - '+sname
 if verbose then mprint,err,_extra=extra
 return,0
endif

;-- extract procedure/function call

index=chk[0]
ntemp=temp[chk[0]: n_elements(temp)-1]
np=n_elements(ntemp)
call=ntemp[0]
for i=0,np-1 do begin
 chk2=stregex(ntemp[i],'\$$',/bool)
 if ~chk2 then break
 if ((i+1) lt (np-1)) then call=[call,ntemp[i+1]] 
endfor

if stregex(call[0], '^pro',/bool) then return,1 else return,2

return,0
end