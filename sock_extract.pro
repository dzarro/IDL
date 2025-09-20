;+
; Project     : VSO
;
; Name        : SOCK_EXTRACT
;
; Purpose     : Extract properties from from IDLnetURL object
;
; Category    : system utility sockets
;
; Syntax      : IDL> sock_extract,ourl
;
; Inputs      : OURL = IDLnetURL object
;
; Outputs     : See keywords
;
; Keywords    : RESPONSE_CODE = IDLnetURL response code
;               RESPONSE_HEADER = IDLnetURL response header
;
; History     : 26-August-2025, Zarro (Retired) - written
;               
; Contact     : dzarro@solar.stanford.edu
;-

pro sock_extract,ourl,err=err,_ref_extra=extra,response_header=response_header
                 
err=''
ok=0b
response_header=''

case 1 of
 n_elements(ourl) ne 1: err='Input must be a scalar object.'
 ~obj_valid(ourl): err='Input must be a valid object.'
 ~obj_isa(ourl,'idlneturl'): err='Input must be a valid IDLnetURL object.'
 else: ok=1b 
endcase
if ~ok then return

ourl->getproperty,_extra=extra,response_header=response_header   
if is_string(response_header) then sock_content,response_header,_extra=extra

return
end
