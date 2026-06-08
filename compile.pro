;+
; Project     : SDAC
;                  
; Name        : COMPILE
;               
; Purpose     : Compile code in string array
;                             
; Category    : system utility 
;               
; Syntax      : IDL> compile,code
;
; Inputs:     : CODE = string array with source code
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

pro compile,code,err=err,_extra=extra,verbose=verbose

verbose=keyword_set(verbose)
err=''
if is_blank(code) then begin
 err='Input code must be non-blank string.'
 mprint,err,_extra=extra
 return
endif

cd,current=cdir
error=0
catch, error
if (error ne 0) then begin
 catch, /cancel
 err=err_state()
 mprint,err,_extra=extra
 message,/reset
 cd,cdir
 return
endif

out_file=get_temp_file('temp.pro')
pro_dir=file_dirname(out_file)
cd,pro_dir

pro_name=file_basename(out_file,'.pro')
out=[code,' ','pro '+pro_name,'return & end']
if verbose then mprint,'Writing to - '+out_file
wrt_ascii,out,out_file,/no_pad
resolve_routine,pro_name,/either,/compile_full_file,quiet=1-verbose

cd,cdir

return & end