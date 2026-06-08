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
;               METHOD = method name if program is an object class definition
;               INDEX = first line in PROG_FILE where CALL is located
;               VERBOSE = set for verbose output
;               FNAME = procedure/function name matching sub_prog or method
;               CODE = source code for program/sub program/method
;               ERR = error string
;                          
; History     : 12-May-2026, Zarro (Retired) - written
;               
; Contact     : dzarro@solar.stanford.edu
;-    

function prog_type,program,method=method,sub_prog=sub_prog,verbose=verbose,call=call,prog_file=prog_file,$
                   index=index,err=err,_extra=extra,fname=fname,class=class,last_compiled=last_compiled,code=code

need_last=arg_present(last_compiled)
need_code=arg_present(code)

err='' & call='' & index=-1 & prog_file='' & fname='' & class=0b & last_compiled='' & code=code

verbose=keyword_set(verbose)
if is_blank(program) then begin
 err='Program name not entered.'
 mprint,err,_extra=extra
 return,0
endif

class=is_string(method)
if class then ptype='Class definition file' else ptype='Program file'
sname=strlowcase(file_basename(program,'.pro'))
if class then pname=sname+'__define' else pname=sname

;-- check for last compiled version

if need_last then begin
 loc=routine_info2(pname,err=err2,/source,verbose=verbose)
 if is_blank(err2) then begin
  if have_tag(loc,'name') && have_tag(loc,'path') then begin
   if strlowcase(loc.name) eq strlowcase(pname) then begin
    if file_test(loc.path,/reg) then last_compiled=loc.path
   endif
  endif
 endif
endif
 
chk=have_proc(pname,out=prog_file,/init)
if ~chk then begin
 err=ptype+' not found - '+pname
 mprint,err,_extra=extra
 return,0
endif
 
if keyword_set(verbose) then mprint,prog_file

;-- find first occurrence of pro or function call

temp=strtrim(rd_ascii(prog_file),2)

case 1 of
 class: begin ftype='Method call' & fname=sname+'::'+method & end
 is_string(sub_prog): begin ftype='Sub-program call' & fname=sub_prog & end
 else: begin ftype='Program call' & fname=pname & end
endcase

tname=str_escape(fname)+' *,'
search='^((pro +('+tname+')+)|(function +('+tname+')+))'
chk=where(stregex(temp,search,/bool,/fold),count)
if verbose then mprint,search,_extra=extra

if count eq 0 then begin
 err=ftype+' not found - '+fname
 mprint,err,_extra=extra
 return,0
endif

;-- extract procedure/function call

index=chk[0]
ntemp=temp[chk[0]: n_elements(temp)-1]
strip_arg,ntemp,call,/quiet,err=err
if is_string(err) then return,0

if need_code then begin
 search='^((pro +)|(function +))'
 chk=where(stregex(ntemp,search,/bool,/fold),count)
 if count gt 1 then last=chk[1]-1 else last=n_elements(ntemp)-1 
 code=ntemp[chk[0]:last]
endif

call=call[0]
ptype=0
if stregex(call, '^pro',/bool,/fold) then ptype=1
if stregex(call, '^func',/bool,/fold) then ptype=2

return,ptype
end