;+
; Project     : SDAC
;                  
; Name        : FILE2BASE64
;               
; Purpose     : Convert file to BASE64 encoded format
;                             
; Category    : system utility 
;               
; Syntax      : IDL> file2base64,file
;
; Inputs:     : FILE = name of file to convert
;              
; Outputs     : None
;
; Keywords    : OUT_FILE = name of converted file [def = input file name with .base64 suffix]
;               COMPRESS = compress via GZIP
;               VERBOSE = set for verbose output
;               ERR = error string
;                          
; History     : 12-May-2026, Zarro (Retired) - written
;               
; Contact     : dzarro@solar.stanford.edu
;-    

pro file2base64,file,err=err,compress=compress,out_file=out_file,verbose=verbose,_ref_extra=extra,overwrite=overwrite

err=''
if is_blank(file) then begin
 err='Missing input filename.'
 pr_syntax,'file2base64,filename
 return
endif

verbose=keyword_set(verbose)
compress=keyword_set(compress)
overwrite=keyword_set(overwrite)

fdir=file_dirname(file)
ifile=file_basename(file)
fname=file_break(ifile,/no_ext)+'.base64'
ofile=concat_dir(fdir,fname)
if is_string(out_file) then ofile=out_file

if file_test(ofile,/reg) && ~overwrite then begin
 mprint,'Encoded file "'+ofile+'" already exists. Use /OVERWRITE.
 return
endif
 
;-- convert file to byte stream

barr=file_stream(file,err=err,compress=compress,_extra=extra)
if is_string(err) then return

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

;-- convert byte stream to BASE64 encoded string and write to output file

aarr=idl_base64(barr)
openw,lun,ofile,/get_lun
aarr=idl_base64(barr)
printf,lun,'Filename: '+ifile+'; Compressed: ' +trim(compress)
printf,lun,aarr
close_lun,lun

if is_blank(out_file) then out_file=ofile
if verbose then mprint,'Wrote BASE64 encoded file - '+ofile

return & end
