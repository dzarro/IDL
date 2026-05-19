;+
; Project     : SDAC
;                  
; Name        : BASE2FILE
;               
; Purpose     : Unconvert BASE64 encoded file
;                             
; Category    : system utility 
;               
; Syntax      : IDL> ASC2FILE,file
;
; Inputs:     : FILE = name of file to unconvert
;              
; Outputs     : None
;
; Keywords    : OVERWRITE = set to overwrite existing file
;               VERBOSE = set for verbose output
;               ERR = error string
;                          
; History     : 12-May-2026, Zarro (Retired) - written
;               
; Contact     : dzarro@solar.stanford.edu
;-    

pro base2file,file,err=err,verbose=verbose,overwrite=overwrite
err=''

if is_blank(file) then begin
 err='Missing input filename.'
 pr_syntax,'base2file,filename
 return
endif

verbose=keyword_set(verbose)
overwrite=keyword_set(overwrite)

if ~file_test(file,/reg) then begin
 err='Input file not found.'
 mprint,err
 return
endif

;-- trap errors

error=0
catch,error
if (error ne 0)  then begin
 err=err_state()
 mprint,err
 catch,/cancel
 message,/reset
 error=0
 return
endif

openr,lun,file,/get_lun
txt=''
chk=strarr(3) & line=0 & fname='' & compressed=0
while ~eof(lun) do begin
 readf,lun,txt
 chk=stregex(txt,'Filename:'+'(.+)'+'; Compressed:'+'(.+)',/ext,/sub)
 if line eq 0 then begin
  fname=strtrim(chk[1],2)
  compressed=fix(chk[2])
 endif
 line=line+1
endwhile
close_lun,lun

;-- decode data

if is_blank(fname) then begin
 err='Invalid input BASE64 encoded file.'
 mprint,err
 return
endif 

if file_test(fname,/reg) && ~overwrite then begin
 mprint,'Decoded file "'+fname+'" already exists. Use /OVERWRITE.
 return
endif

decoded=idl_base64(txt)
if compressed then begin
 if verbose then mprint,'Decompressing bytes...'
 decoded=zlib_uncompress(decoded,/gzip)
endif

if verbose then mprint,'Wrote decoded file - '+fname
openw,lun,fname,/get_lun
writeu,lun,decoded
close_lun,lun

return & end
