;+
; Project     : HESSI
;                  
; Name        : FILE_DELETE2
;               
; Purpose     : wrapper around FILE_DELETE that checks protections
;                             
; Category    : system utility
;               
; Syntax      : IDL> file_delete2,files
;
; Inputs      : FILES = files or directory names
;                                        
; Outputs     : None
;
; Keywords    : RECURSIVE = set to recurse on directories
;                   
; History     : 10-Jan-2019, Zarro (ADNET) - written
;               13-Nov-2025, Zarro (Consultant/Retired) - fixed bug with missing links
;
; Contact     : dzarro@solar.stanford.edu
;-    

pro file_delete2,files,_extra=extra,err=err,verbose=verbose

err=''
if is_blank(files) then return

for i=0,n_elements(files)-1 do begin
 err=''
 error=0
 catch,error
 if error ne 0 then begin
  err=err_state()
  if verbose then mprint,err,_extra=extra
  message,/reset
  catch,/cancel
  continue
 endif

 tfile=strtrim(files[i],2)
 if is_blank(tfile) then continue
 
 ;is_file=file_test2(tfile,/reg,_extra=extra)
 is_direc=file_test2(tfile,/direc,_extra=extra)
 ;if ~is_file && ~is_direc then begin
 ;err='Non-existent file/directory - '+tfile
 ;if ~quiet then mprint,err  
 ;endif else begin
 
 if is_direc then begin
  fdir=file_dirname(tfile)
  if (fdir eq '.') || (fdir eq '') then tfile=concat_dir(curdir(),tfile)
 endif
 file_delete,tfile,_extra=extra,/allow_nonexistent,verbose=verbose

endfor

return & end
