;+
; Project     : VSO
;
; Name        : STR_TOARR
;
; Purpose     : Convert string with CR's or LF's into an array of separated lines
;
; Category    : utility string
;
; Syntax      : IDL> soutput=str_toarr(sinput)
;
; Inputs      : INPUT = scalar string to convert
;               
; Outputs     : OUTPUT = array of strings  
;
; History     : 11-September-2025 Zarro (Consultant/Retired) - written           
;-

function str_toarr,sinput

if ~is_string(sinput) then return,''
if n_elements(sinput) eq 1 then return,buff2arr(byte(sinput)) else return,sinput

;return,byte2str(byte(iarray),newline=13,skip=2) else return,''

end