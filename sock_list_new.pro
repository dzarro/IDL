;+
; Project     : VSO
;
; Name        : SOCK_LIST_NEW
;
; Purpose     : Wrapper around IDLnetURL object to list URL.
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_list_new,url,output
;
; Inputs      : URL = URL to list
;
; Outputs     : OUTPUT = string or byte array (if /buffer) 
;
; Keywords    : BUFFER = return output as byte array
;               NO_CHECK = don't check input URL
;               CACHE = cache and return last cache results
;               CLEAR_CACHE = clear cache
;
; History     : 20-July-2011, Zarro (ADNET) - written
;               7-November-2013, Zarro (ADNET) 
;               - renamed from SOCK_CAT to SOCK_LIST
;               31-December-2013, Zarro (ADNET)
;               - added /BUFFER keyword
;               10-Feb-2015, Zarro (ADNET)
;               - pass input URL directly to IDLnetURL2 to parse
;                 PROXY keyword properties in one place
;               15-June-2016, Zarro (ADNET)
;                - added call to SOCK_DIR for FTP listing
;               16-June-2016, Zarro (ADNET)
;               - deprecated /OLD_WAY (caused recursion situations)
;               16-Sep-2016, Zarro (ADNET)
;               - added call to URL_FIX
;               10-Oct-2016, Zarro (ADNET)
;               - added check for URL redirect
;               21-Dec-2016, Zarro (ADNET)
;               - fixed bug with listing FTP sites and added /cache
;               30-January-2017, Zarro (ADNET)
;               - added check for SSL support
;               8-December-2017, Zarro (ADNET)
;               - added more error checking
;               20-December-2018, Zarro (ADNET)
;               - added CLEAR_CACHE
;                6-March-2019, Zarro (ADNET)
;               - renamed SOCK_LIST_NEW
;                4-October-2019, Zarro (ADNET)
;               - improved error propagation via keyword inheritance
;                11-July-2025, Zarro (Retired)
;               - added check for gzip encoded response output
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sock_list_new,url,output,_ref_extra=extra,err=err,no_check=no_check,$
              cache=cache,clear_cache=clear_cache

common sock_list,fifo
forward_function zlib_uncompress
err=''
output=''

if ~is_url(url,_extra=extra,/scalar,err=err) then return

;-- cache for list results

if ~obj_valid(fifo) then fifo=obj_new('fifo')
if keyword_set(clear_cache) then if obj_valid(fifo) then obj_destroy,fifo

cache=keyword_set(cache)

if cache then begin
 last=fifo->get(url,status=status)
 if status then begin
  output=last
  if (n_params() eq 1) then if is_string(output) then print,output
  return
 endif
endif

;-- redirect FTP

if is_ftp(url) then begin
 sock_dir_ftp,url,output,err=err,_extra=extra
 if (n_params() eq 1) then if is_string(output) then print,output
 if is_blank(err) then fifo->set,url,output
 return
endif

;-- catch miscellaneous errors

error=0
catch,error
if (error ne 0) then begin
 mprint,err_state()
 catch, /cancel
 message,/reset  
 goto,bail  
endif

durl=url_fix(url,_extra=extra)
stc=url_parse(durl)
query=stc.query

;-- pre-check URL 

if ~keyword_set(no_check) && is_blank(query) then begin
 chk=sock_check(durl,_extra=extra,err=err,location=location,used_browser=used_browser)
 if ~chk then begin
  if is_blank(err) then err='URL unavailable.'
  mprint,err
  return
 endif
 if is_string(location) then durl=location
endif
  
;-- list URL 

ourl=obj_new('idlneturl2',durl,_extra=extra,browser=used_browser)
output = ourl->Get(/buffer)    

bail:

if obj_valid(ourl) then begin
 sock_message,ourl,encoding=encoding,_extra=extra,err=err
 obj_destroy,ourl
endif

if ~is_byte(output) then begin
 if is_blank(err) then err='Listing failed.
 mprint,err 
 return
endif

;-- convert bytes to string

if is_string(encoding) then if encoding eq 'gzip' then output=zlib_uncompress(output,/gzip) 
output=buff2arr(output)
if (n_params() eq 1) then if is_string(output) then print,output
fifo->set,url,output

return & end  
