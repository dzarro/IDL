;+
; Name        : SOCK_REDIRECT
;
; Purpose     : Determine redirect location of a URL
;
; Category    : utility system sockets
;
; Syntax      : IDL> sock_redirect,url,redirect
;
; Inputs      : URL = remote URL file name to check
;
; Outputs     : REDIRECT = redirected URL location
;
; Keywords    : ERR = error string
;
; History     : 27-Nov-2019, Zarro (ADNET) - written
;               13-Nov-2025, Zarro (Consultant/Retired) - inserted call SOCK_HEAD
;-

pro sock_redirect,url,redirect,_ref_extra=extra

h=sock_head(url,location=redirect,_extra=extra)

return

if ~is_url(url,_extra=extra,/scalar,err=err) then return
chk=have_network(url,location=location,err=err,_extra=extra)
if ~chk || is_string(err) || is_blank(location) then return

purl=url_parse(url)
lurl=url_parse(location)
purl.scheme=lurl.scheme
purl.host=lurl.host
purl.port=lurl.port
redirect=url_join(purl,_extra=extra)

end
