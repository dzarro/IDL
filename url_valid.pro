;+
; Project     : VSO
;
; Name        : URL_VALID
;
; Purpose     : Validate a URL by sending a HEAD request to it.
;
; Category    : utility sockets
;
; Inputs      : URL = URL to validate
;
; Outputs     : OK = 1/0 is valid or not
;
; Keywords    : ERR = error message
;
; History     : 18-Jan-2019, Zarro (ADNET) - written
;                5-Nov-2019, Zarro (ADNET) - return RESPONSE_CODE as keyword
;
; Contact     : DZARRO@SOLAR.STANFORD.EDU
;-

function url_valid,url,_ref_extra=extra

chk=sock_check(url,_extra=extra)

return,chk
end
