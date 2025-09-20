;+
; Project     : VSO
;
; Name        : SOCK_ERROR
;
; Purpose     : Parse socket errors
;
; Category    : system utility sockets
;
; Syntax      : IDL> sock_error,url,code,response_code=response_code
;
; Inputs      : URL = URL being checked
;               CODE = status code returned in HTTP response header
;
; Outputs     : None
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
;
; Contact     : dzarro@solar.stanford.edu
;-

pro sock_error,url,code,response_code=response_code,err=err,verbose=verbose,location=location,resp_array=resp_array,debug=debug

verbose=keyword_set(verbose)
err='' & rerr='' & serr=''

if is_number(code) then if stregex(trim(code),'^(3|2)',/bool) then return

;-- check response codes

if is_number(response_code) then begin
 rerr=sock_decode(response_code)
 rerr='Response code = '+trim(response_code)+'. '+rerr
 if keyword_set(debug) then mprint,rerr
endif

;-- check status codes

if is_string(resp_array) then begin
 serr=resp_array[0]
 if verbose then mprint,serr
endif

if is_string(serr) then err=serr

return & end
