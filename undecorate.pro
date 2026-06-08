;+
; Project     : SDAC
;                  
; Name        : UNDECORATE
;               
; Purpose     : Undecorate decorated program
;                             
; Category    : system utility 
;               
; Syntax      : IDL> undecorate,program
;
; Inputs:     : PROGRAM = name of procedure or function to decorate
;
; Outputs     : None
;
; Keywords    : SUB_PROG = name of procedure or function within program to decorate 
;                         (optional if a sub program is embedded within program code)
;               METHOD = method name if program is an object class definition
;               VERBOSE = set for verbose output
;               ERR = error string
;                          
; History     : 7-Jun-2026, Zarro (Retired) - written
;               
; Contact     : dzarro@solar.stanford.edu
;-    

pro undecorate,program,_ref_extra=extra,err=err

err=''
p=prog_type(program,_extra=extra,code=code,err=err)
if (p eq 0)|| is_string(err) then return

compile,code,err=err,_extra=extra

return & end
