;+
; Project     : VSO
;
; Name        : KEY_VALUE
;
; Purpose     : Extract the value of a key from a header array (e.g. KEY: VALUE)
;
; Category    : utility string
;
; Syntax      : IDL> value=key_value(header,key)
;
; Inputs      : HEADER = string array of KEY: VALUE pairs
;               KEY = string key name to determine value
;               
; Outputs     : VALUE = string value associated with key 
;
; History     : 11-September-2025 Zarro (Consultant/Retired) - written            
;-

function key_value,header,key

if ~is_string(header) || ~is_string(key) then return,''

items=strtrim(stregex(header,'([^\:]+)\:(.+)',/extract,/sub),2)

keys=strupcase(items[1,*])
values=items[2,*]
skey=strupcase(strtrim(key[0],2))
svalue=''
chk=where(skey eq keys,count)
if count gt 0 then svalue=values[chk[0]]

return,svalue

end
 