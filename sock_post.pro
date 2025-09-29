;+
; Project     : VSO
;
; Name        : SOCK_POST
;
; Purpose     : Wrapper around IDLnetURL object to issue POST request
;
; Category    : utility system sockets
;
; Syntax      : IDL> output=sock_post(url,content)
;
; Inputs      : URL = remote URL file to send content
;               CONTENT = string content to post
;
; Outputs     : OUTPUT = server response
;
; Keywords    : FILE = if set, OUTPUT is name of file containing response
;
; History     : 23-November-2011, Zarro (ADNET) - Written
;               2-November-2014, Zarro (ADNET)
;                - allow posting blank content (for probing)
;               16-Sep-2016, Zarro (ADNET)
;               - added call to URL_FIX
;               9-Oct-2018, Zarro (ADNET)
;               - improved error checking
;               3-Mar-2019, Zarro (ADNET)
;               - more error checking
;               4-Oct-2019, Zarro (ADNET) 
;               - initialized CODE
;               8-Nov-2019, Zarro (ADNET)
;               - improved error checking
;               22-Aug-2025, Zarro (Retired)
;               - Improved error handling
;
; Contact     : dzarro@solar.stanford.edu
;-

function sock_post,url,content,err=err,file=file,_ref_extra=extra,debug=debug,old_version=old_version

err='' & output=''
debug=keyword_set(debug)
old_ver=keyword_set(old_version)
new_ver=since_version('8.6.1') && ~old_ver
rfile='' & efile=''

if ~is_url(url,_extra=extra,/scalar,err=err) then return,''

cdir=curdir()
error=0
catch, error
if (error ne 0) then begin
 mprint,err_state()
 catch,/cancel
 message,/reset
 goto,bail
endif

durl=url_fix(url,_extra=extra)
stc=url_parse(durl)
query=stc.query

ourl=obj_new('idlneturl2',durl,_extra=extra,debug=debug)

if is_string(content) then dcontent=content else dcontent=''

;-- have to send output to writeable temp directory if older than
;   IDL 8.6.1. New version accepts /STRING_ARRAY

if new_ver then begin
 mprint,'Posting...'
 rfile = ourl->put(dcontent,/buffer,/post,/string_array)
 mprint,'Posted.'
endif else begin
 sdir=session_dir()
 cd,sdir
 rfile = ourl->put(dcontent,/buffer,/post)
endelse

;-- clean up

bail: 

if ~new_ver then cd,cdir
if obj_valid(ourl) then begin
 sock_message,ourl,_extra=extra,response_file=efile,response_header=response_header,err=err
 obj_destroy,ourl
endif

;-- check for errors

if debug then begin
 if is_string(efile) then begin
  if file_test(efile,/regular) && ~file_test(efile,/zero_length) then print,rd_ascii(efile)
 endif
 if is_blank(rfile) && is_string(response_header) then print,response_header
endif

if is_string(rfile) then begin
 if keyword_set(file) then begin
  if new_ver then begin
   rname=get_temp_file()
   wrt_ascii,rfile,rname
   output=rname
  endif else output=rfile
 endif else begin
  if new_ver then begin
   output=rfile 
   (SCOPE_VARFETCH('output', /enter, LEVEL=1)) = output
  endif else begin
   mprint,'Using old version'
   file_copy,rfile,concat_dir(curdir(),'test.xml'),/force,/over
   if file_test(rfile,/regular) && ~file_test(rfile,/zero_length) then output=rd_ascii(rfile)
   file_delete,sdir,/recursive,/allow_nonexistent 
  endelse
 endelse
endif

if is_blank(output) then begin
 if is_blank(err) then err='HTTP post failed.'
 mprint,err
endif 

return,output

end  
