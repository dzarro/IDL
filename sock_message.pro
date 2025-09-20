;+
; Project     : VSO
;
; Name        : SOCK_MESSAGE
;
; Purpose     : Parse socket errors
;
; Category    : system utility sockets
;
; Syntax      : IDL> sock_error,ourl,code=code,response_code=response_code
;
; Inputs      : OURL = IDLnetURL object
;               
; Outputs     : See keywords
;
; Keywords    : RESPONSE_CODE = response code returned by IDLnetURL
;               (can differ from CODE if SSL error) 
;               ERR = error string
;               VERBOSE = set to print ERR
;
; History     : 30 January 2017, Zarro (ADNET) - written
;               10 May 2017, Zarro (ADNET) 
;                - added more informative error messages
;               27 November 2017, Zarro (ADNET)
;                - added extra check for secure URL
;               5 December 2017, Zarro (ADNET)
;                - added checks for additional network errors
;               18-January 2019, Zarro (ADNET)
;                - added more known network error codes
;               29-August 2019, Zarro (ADNET)
;                - added more error checks
;                3-October-2019, Zarro (ADNET)
;                - added call to SOCK_DECODE
;                25-August-2025, Zarro (Retired)
;                - improved error message handling
;                - renamed to SOCK_MESSAGE
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sock_message,ourl,code=code,response_code=response_code,err=err,verbose=verbose,resp_array=resp_array,_ref_extra=extra

resp_array='' & response_code=0 & code=0 & err=''

if obj_valid(ourl) then begin
 sock_extract,ourl,resp_array=resp_array,_extra=extra,code=code,response_code=response_code
endif else return

scode=strtrim(code,2)
nok=stregex(scode,'^(3|4|5|0)',/bool) 
if nok then begin
 if is_string(resp_array) then err=resp_array[0] else err='No HTTP response.'
endif

if keyword_set(verbose) then begin
 if nok then begin
  if is_number(response_code) then if (response_code ne 42) && (response_code ne code) then mprint,sock_decode(response_code)
 endif
endif

return & end

