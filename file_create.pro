;+
; Project     : VSO
;
; Name        : FILE_CREATE
;
; Purpose     : Create an empty regular file (if it doesn't exist)
;
; Category    : utility system
;
; Syntax      : IDL> file_create,file
;
; Inputs      : FILE = string file name to create
;
; Keywords    : ERR = error string
;
; History     : 26 January 2019, Zarro (ADNET) - written
;               26-Nov-2025, Zarro (Consultant/Retired) - added call to CHMOD
;-

pro file_create,file,err=err,verbose=verbose,_extra=extra

err=''
verbose=keyword_set(verbose)
if ~scalar_string(file,err=err) then begin
 mprint,err,_extra=extra
 return
endif

tfile=local_name(file)
lfile=file_basename(tfile)
ldir=file_dirname(tfile)
if (ldir eq '.' || ldir eq '') then ldir=curdir()
lfile=concat_dir(ldir,lfile)

info=file_info(lfile)
if info.exists then begin
 err=lfile+' already exists'
 mprint,err,_extra=extra
 return
endif

case 1 of
 ~file_test(ldir,/direct): err='Non-existent parent directory: ' +ldir 
 ~file_test(ldir,/write): err='Denied write access to: '+ldir
 else: ok=1
endcase
if is_string(err) then begin
 mprint,err
 return
endif

openw,lun,lfile,/get_lun
close_lun,lun

if ~file_test(lfile,/reg) then begin
 err='File not created: '+dfile
 mprint,err,_extra=extra
endif else begin
 if verbose then mprint,'File created: '+lfile,_extra=extra
endelse

if is_struct(extra) then chmod,lfile,_extra=extra,err=err

return
end
