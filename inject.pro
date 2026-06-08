;+
; Project     : SDAC
;                  
; Name        : INJECT
;               
; Purpose     : Inject code into a program
;                             
; Category    : system utility 
;               
; Syntax      : IDL> inject,code,program,line
;
; Inputs:     : CODE = string array with source code to inject
;               PROGRAM = name of program file to inject
;               LINE = line number in program where to inject
;              
; Outputs     : None
;
; Keywords    : VERBOSE = set for verbose output
;               ERR = error string
;                          
; History     : 8-Jun-2026, Zarro (Retired) - written
;               
; Contact     : dzarro@solar.stanford.edu
;-    

pro inject,code,program,line,err=err,_extra=extra

;-- error checks

if is_blank(code) then begin
 err='Input code must be non-blank string.'
 mprint,err,_extra=extra
 return
end

p=prog_type(program,prog_file=pfile,err=err,_extra=extra)
if (p eq 0) || is_string(err) then return

if ~is_number(line) then begin
 err='Input line number must be numeric.'
 mprint,err,_extra=extra
 return
endif

source=rd_ascii(pfile)
np=n_elements(source)
if abs(line) ge np then begin
 err='Line number exceeds source size.'
 mprint,err,_extra=extra
 return
endif

if n_elements(code) eq 1 then begin
 scode='"'+code+'"'
 scode='s=execute('+scode+')'
endif else scode=code

;-- insert code and compile new source code

nsource=[source[0:line-1],scode,source[line:np-1]]
compile,nsource,err=err,_extra=extra

return & end