;+
; Project     : VSO
;
; Name        : SOCK_STREAM
;
; Purpose     : Stream a file from a URL into a buffer
;
; Category    : utility system sockets
;
; Syntax      : IDL> buffer=sock_stream(url)
;
; Inputs      : URL = remote URL file name to stream
;
; Outputs     : BUFFER = byte array
;
; Keywords    : COMPRESS = compress buffer
;
; History     : 13-Jan-2016, Zarro (ADNET) - Written
;               23-Jun-2018, Zarro (ADNET) - add QUIET
;               24-Mar-2019, Zarro (ADNET) - added SOCK_ERROR
;                4-Oct-2019, Zarro (ADNET) - initialized CODE
;               28-Aug-2025, Zarro (Retired) - streamlined
;-

function sock_stream,url,compress=compress,err=err,_ref_extra=extra

forward_function zlib_compress,zlib_uncompress
err=''

if ~is_url(url,err=err,_extra=extra) then begin
 pr_syntax,'buffer=sock_stream,url [,/compress]'
 return,0b
endif

;-- initialize object 

error=0
catch,error
if (error ne 0) then begin
 mprint,err_state()
 catch,/cancel
 message,/reset
 goto,bail
endif

durl=url_fix(url,_extra=extra)
ourl=obj_new('idlneturl2',durl,_extra=extra)
buffer = ourl->get(/buffer)  

bail:

if obj_valid(ourl) then begin
 sock_message,ourl,_extra=extra,encoding=encoding,err=err
 obj_destroy,ourl
endif

if ~is_byte(buffer) then begin
 if is_blank(err) then err='Stream failed.
 mprint,err 
 return,0b
endif

if keyword_set(compress) then begin
 if (encoding ne 'gzip') then buffer=zlib_compress(temporary(buffer),/gzip)
endif else begin
 if (encoding eq 'gzip') then buffer=zlib_uncompress(temporary(buffer),/gzip)
endelse

return,buffer

end  
